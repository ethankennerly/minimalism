package com.finegamedesign.minimalism
{
    import flash.utils.Dictionary;
    import org.flixel.*;
   
    public class PlayState extends FlxState
    {
        private var state:String;
        private var instructionText:FlxText;
        private var waveText:FlxText;
        private var scoreText:FlxText;
        private var player:Player;
        private var enemies:FlxGroup;
        private var gibs:FlxEmitter;
        private var driftDistance:int = 60;
        private var driftTime:Number = 0.25;
        private var middleY:int = 240;
        private var targetY:int;
        private var direction:int;
        private var signDirection:int;
        private var truck:Truck;
        private var baseVelocityX:int = -160;
        private var velocityX:int;
        private var road:Road;
        private var roads:FlxGroup;
        private var baseSpawnTime:Number = 15.0;
        private var progressTimer:FlxTimer;
        private var baseProgressTime:Number = 1.0;
        private var progressTime:Number;
        private var distance:int;
        private var signDistance:int;
        private var warnings:FlxGroup;
        private var warningFrame:int;
        private var warning:Warning;
        private var obstacles:FlxGroup;
        private var obstacle:Warning;
        private var signs:FlxGroup;
        private var sign:FlxSprite;
        private var levelDistance:int = 256;

        override public function create():void
        {
            super.create();
            // FlxG.visualDebug = true;
            FlxG.worldBounds = new FlxRect(0, 100, 320, 380);
            roads = new FlxGroup();
            road = new Road();
            var roadY:int = middleY - road.height / 2;
            for (var roadX:int = 0; roadX < FlxG.width + 2 * road.width; roadX += int(road.width - 3)) {
                road = new Road(roadX, roadY);
                roads.add(road);
            }
            add(roads);
            warnings = new FlxGroup();
            for (var concurrentWarning:int = 0; concurrentWarning < 4; concurrentWarning++) {
                warning = new Warning();
                warning.exists = false;
                warnings.add(warning);
            }
            add(warnings);
            obstacles = new FlxGroup();
            for (var concurrentObstacle:int = 0; concurrentObstacle < 4; concurrentObstacle++) {
                obstacle = new Warning();
                obstacle.exists = false;
                obstacles.add(obstacle);
            }
            add(obstacle);
            signs = new FlxGroup();
            for (var concurrentSigns:int = 0; concurrentSigns < 4; concurrentSigns++) {
                sign = new Sign();
                sign.exists = false;
                signs.add(sign);
            }
            add(signs);
            enemies = new FlxGroup();
            for (var concurrentTruck:int = 0; concurrentTruck < 4; concurrentTruck++) {
                truck = new Truck();
                truck.exists = false;
                enemies.add(truck);
            }
            progressTimer = new FlxTimer();
            direction = 1;
            signDirection = 1;
            signDistance = 5;
            player = new Player(40, middleY + direction * driftDistance);
            player.y -= player.height / 2;
            targetY = middleY + direction * driftDistance;
            add(player);
            addHud();
            if (FlxG.score < levelDistance * 2) {
                FlxG.score = Math.max(0, FlxG.score - levelDistance / 3);
                distance = FlxG.score;
            }
            else {
                distance = levelDistance;
                FlxG.score = levelDistance;
                FlxG.timeScale = 2.0;
                FlxG.log("Double speed");
            }
            setVelocityXByDistance(distance);
            progressTimer.start(progressTime, 1, progress);
            Warning.fuelUp = fuelUp;
            state = "play";
        }

        /**
         * Player drifts to other side.
         */
        private function switchLane():void
        {
            direction = -direction;
            var directions:Dictionary = new Dictionary();
            directions[-1] = "left";
            directions[1] = "right";
            player.play(directions[direction]);
            targetY = middleY + direction * driftDistance - player.height / 2;
            player.velocity.y = 2 * direction * driftDistance * (1.0 / driftTime);
            FlxG.play(Sounds.turn);
            // FlxG.log("switchLane: at " + player.velocity.y + " to " + targetY);
        }

        private function mayStopDrift():void
        {
            if ("play" == state) {
                if (direction < 0 && player.y <= targetY
                        || 0 < direction && targetY <= player.y) {
                    player.velocity.y = 0;
                    player.y = targetY;
                    player.play("idle");
                }
            }
            else if ("lose" == state) {
                player.velocity.y = 0;
            }
        }

        private function spawnTruck(warningFrame:int):void
        {
            truck = Truck(enemies.getFirstAvailable());
            placeInRoad(truck, signDirection, 1.5, 1.0);
            truck.frame = warningFrame;
            truck.sound = true;
        }
            
        private function spawnObstacle(warningFrame:int):void
        {
            obstacle = Warning(obstacles.getFirstAvailable());
            placeInRoad(obstacle, -signDirection, 0.5, 0.5);
            obstacle.frame = warningFrame;
            obstacle.solid = true;
            FlxG.log("spawn wf " + warningFrame);
        }
        
        private function placeInRoad(truck:FlxSprite, signDirection:int, speed:Number, collisionWidthRatio:Number):void
        {
            truck.revive();
            truck.y = middleY + -signDirection * driftDistance - truck.height / 2;
            truck.x = -speed * baseSpawnTime * baseVelocityX;
            truck.velocity.x = speed * velocityX;
            truck.width = collisionWidthRatio * truck.frameWidth;
            truck.offset.x = 0.5 * (1.0 - collisionWidthRatio) * truck.frameWidth;
            add(truck);
        }

        private function setVelocityXByDistance(distance:int):void
        {
            var minVelocityX:int = -640;
            if (minVelocityX < velocityX) {
                setVelocityX(
                    Math.max(minVelocityX,
                        int(distance / levelDistance * (minVelocityX - baseVelocityX) + baseVelocityX)));
                FlxG.log("speed up " + velocityX);
            }
        }
        
        private function progress(timer:FlxTimer):void
        {
            distance++;
            FlxG.score += 1;
            if ("play" != state) {
                return;
            }
            if (signDistance <= distance) {
                setVelocityXByDistance(distance);
                var warningDistance:int = levelDistance / 2;
                var isWarning:Boolean = warningDistance < distance 
                    && (levelDistance * 2 <= distance || distance < warningDistance + 60 || Math.random() < 0.25);
                var isBritain:Boolean = Math.random() < 0.5;
                signDirection = isBritain ? -1 : 1;
                var group:FlxGroup = isWarning ? warnings : signs;
                var columns:int = 4;
                var spawn:Function = isWarning ? spawnObstacle : spawnTruck;
                sign = FlxSprite(group.getFirstAvailable());
                sign.x = FlxG.width;
                sign.y = FlxG.height / 8 - sign.height / 2;
                sign.revive();
                sign.solid = false;
                var firstDistance:int = isWarning ? warningDistance : 0;
                var progression:Number = (distance - firstDistance) / (levelDistance - firstDistance);
                if (levelDistance < distance && distance < levelDistance * 2) {
                    progression = Math.random();
                }
                // var progression:Number = distance / levelDistance;
                var row:int = Math.min(sign.frames / columns - 1, 
                    int((sign.frames - 1) / columns) * progression);
                if (isWarning) {
                    if (distance < levelDistance * 2) {
                        row = Math.min(row, warning.frames / columns - 1);
                    }
                    else {
                        row = (warning.frames - 1) / columns;
                    }
                }
                sign.frame = columns * row + (isBritain ? 1 : 0);
                sign.velocity.x = 0.5 * velocityX;
                warningFrame = columns * row + 3;
                FlxG.log("sign r " + row + " f " + sign.frame + " p " + progression.toFixed(2));
                // FlxG.log("warning velocity " + sign.velocity.x);
                spawn(warningFrame);
                signDistance = distance + 14;
                if (isWarning && warningFrame == Warning.gas) {
                    FlxG.log("gas " + distance + " frame " + warningFrame + " frames " + sign.frames);
                    signDistance += int.MAX_VALUE;
                    fuelUp();
                }
                // FlxG.log("signDistance " + signDistance);
            }
            progressTimer.start(progressTime, 1, progress);
        }
        
        private function addHud():void
        {
            instructionText = new FlxText(0, 0, FlxG.width, 
                "CLICK OR PRESS SPACEBAR SWITCH SIDES");
            instructionText.color = MenuState.textColor;
            instructionText.scrollFactor.x = 0.0;
            instructionText.scrollFactor.y = 0.0;
            instructionText.alignment = "center";
            add(instructionText);
            waveText = new FlxText(0, 0, 100, "");
            waveText.color = MenuState.textColor;
            waveText.scrollFactor.x = 0.0;
            waveText.scrollFactor.y = 0.0;
            add(waveText);
            scoreText = new FlxText(FlxG.width - 50, 0, 100, " of " + levelDistance * 2);
            scoreText.color = MenuState.textColor;
            scoreText.scrollFactor.x = 0.0;
            scoreText.scrollFactor.y = 0.0;
            add(scoreText);
            scoreText = new FlxText(FlxG.width - 120, 0, 100, "");
            scoreText.color = MenuState.textColor;
            scoreText.scrollFactor.x = 0.0;
            scoreText.scrollFactor.y = 0.0;
            add(scoreText);
        }

		override public function update():void 
        {
            updateInput();
            mayStopDrift();
            enemies.update();
            FlxG.overlap(player, enemies, collide);
            FlxG.overlap(player, obstacles, collide);
            updateHud();
            super.update();
        }

        private function updateHud():void
        {
            if ("play" == state) {
                scoreText.text = "DISTANCE " + FlxG.score;
            }
        }

        private function lose():void
        {
            FlxG.switchState(new MenuState());
        }

        private function win():void
        {
            setVelocityX(0);
            FlxG.switchState(new MenuState());
        }

        private function stop():void
        {
            setVelocityX(0);
            progressTimer.stop();
        }
        
        private function collide(me:FlxObject, you:FlxObject):void
        {
            var player:FlxSprite = FlxSprite(me);
            var enemy:FlxSprite = FlxSprite(you);
            if ("play" == state) {
                enemy.solid = false;
                FlxG.timeScale = 1.0;
                Player(player).play("collide");
                enemy.frame--;
                if (player.y == enemy.y || player.x + player.width / 2 < enemy.x) {
                    enemy.x = player.x + player.width - enemy.offset.x;
                }
                var showSigns:Boolean = false;
                if (showSigns) {
                    if (enemy is Truck) {
                        truck = Truck(enemies.getFirstAvailable());
                        truck.frame = enemy.frame - 1;
                        truck.reset(enemy.x + enemy.width, middleY + driftDistance - truck.height / 2);
                        truck = Truck(enemies.getFirstAvailable());
                        truck.frame = enemy.frame - 2;
                        truck.reset(enemy.x + enemy.width, middleY - driftDistance - truck.height / 2);
                    }
                    else if (enemy is Warning) {
                        warning = Warning(warnings.getFirstAvailable());
                        warning.frame = enemy.frame - 1;
                        warning.reset(enemy.x + enemy.width, middleY - driftDistance - warning.height / 2);
                        warning = Warning(warnings.getFirstAvailable());
                        warning.frame = enemy.frame - 2;
                        warning.reset(enemy.x + enemy.width, middleY + driftDistance - warning.height / 2);
                    }
                }
                FlxG.play(Sounds.explosion);
                FlxG.camera.shake(0.05, 0.5, null, false, FlxCamera.SHAKE_HORIZONTAL_ONLY);
                stop();
                instructionText.text = "YOU CRASHED";
                FlxG.fade(0xFF000000, 4.0, lose);
                state = "lose";
            }
        }

        private function fuelUp():void
        {
            FlxG.timeScale = 1.0;
            player.solid = false;
            FlxG.score += 1;
            instructionText.text = "YOU MADE IT!  FUEL UP!";
            state = "win";
            FlxG.fade(0xFFFFFFFF, 3.0, win);
        }
        
        private function setVelocityX(v:int):void
        {
            velocityX = v;
            for each (road in roads.members) {
                road.velocity.x = 0.5 * v;
            }
            for each (warning in warnings.members) {
                warning.velocity.x = 0.5 * v;
            }
            for each (obstacle in obstacles.members) {
                obstacle.velocity.x = 0.5 * v;
            }
            // FlxG.log("setVelocityX: obstacle " + obstacle.velocity.x);
            for each (sign in signs.members) {
                sign.velocity.x = 0.5 * v;
            }
            for each (truck in enemies.members) {
                truck.velocity.x = 1.5 * v;
            }
            progressTime = baseProgressTime * baseVelocityX / Math.min( -0.0625, v);
            // FlxG.log("setVelocityX: progress " + progressTime);
        }
        
        /**
         * Press SPACE, or click mouse.
         * To make it harder, play 2x speed: press Shift+2.  
         * To make it normal again, play 1x speed: press Shift+1.  
         */ 
        private function updateInput():void
        {
            if ("play" == state) {
                if (FlxG.mouse.justPressed() || FlxG.keys.justPressed("SPACE") || FlxG.keys.justPressed("X")) {
                    switchLane();
                }
            }
            if (FlxG.keys.pressed("SHIFT")) {
                if (FlxG.keys.justPressed("ONE")) {
                    FlxG.timeScale = 1.0;
                }
                else if (FlxG.keys.justPressed("TWO")) {
                    FlxG.timeScale *= 2.0;
                }
                else if (FlxG.keys.justPressed("THREE")) {
                    FlxG.timeScale *= 0.5;
                }
                else if (FlxG.keys.justPressed("NINE")) {
                    player.solid = !player.solid;
                    player.alpha = 0.5 + (player.solid ? 0.5 : 0.0);
                }
            }
        }
    }
}