package com.finegamedesign.minimalism
{
    import flash.utils.Dictionary;
    import flash.utils.getTimer;
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
        private var spawnTimer:FlxTimer;
        private var baseSpawnTime:Number = 5.0;
        private var spawnTime:Number;
        private var progressTimer:FlxTimer;
        private var baseProgressTime:Number = 1.0;
        private var progressTime:Number;
        private var distance:int;
        private var signDistance:int;
        private var warnings:FlxGroup;
        private var warningFrame:int;
        private var warning:Warning;
        private var signs:FlxGroup;
        private var sign:FlxSprite;

        override public function create():void
        {
            FlxG.score = 0;
            // FlxG.visualDebug = true;
            super.create();
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
            signs = new FlxGroup();
            for (var concurrentSigns:int = 0; concurrentSigns < 4; concurrentSigns++) {
                sign = new Sign();
                sign.exists = false;
                signs.add(sign);
            }
            add(signs);
            enemies = new FlxGroup();
            for (var concurrentTruck:int = 0; concurrentTruck < 2; concurrentTruck++) {
                truck = new Truck();
                truck.exists = false;
                enemies.add(truck);
            }
            spawnTimer = new FlxTimer();
            progressTimer = new FlxTimer();
            distance = 0;
            direction = 1;
            signDirection = 1;
            signDistance = 10;
            player = new Player(40, middleY + direction * driftDistance);
            player.y -= player.height / 2;
            targetY = middleY + direction * driftDistance;
            add(player);
            addHud();
            setVelocityX(baseVelocityX);
            FlxG.globalSeed = getTimer();
            progressTimer.start(progressTime, 1, progress);
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
        
        private function spawnTruck(timer:FlxTimer):void
        {
            truck = Truck(enemies.getFirstAvailable());
            truck.velocity.x = 2 * velocityX;
            placeInRoad(truck, signDirection);
        }
            
        private function spawnWarning(timer:FlxTimer):void
        {
            warning = Warning(warnings.getFirstAvailable());
            warning.frame = warningFrame;
            warning.solid = true;
            warning.velocity.x = 0.5 * velocityX;
            placeInRoad(warning, -signDirection);
        }
        
        private function placeInRoad(truck:FlxSprite, signDirection:int):void
        {
            truck.revive();
            truck.y = middleY + -signDirection * driftDistance - truck.height / 2;
            truck.x = 640;
            add(truck);
        }
        
        private function progress(timer:FlxTimer):void
        {
            distance++;
            FlxG.score += 1;
            if (255 <= distance) {
                FlxG.score += 1;
                instructionText.text = "YOU MADE IT!  WELCOME HOME.";
                stop();
                state = "win";
                FlxG.fade(0xFFFFFFFF, 3.0, win);
                return;
            }
            
            if (signDistance <= distance) {
                spawnTimer.stop();
                var isWarning:Boolean = 0.5 <= Math.random();
                var isBritain:Boolean = 0.5 <= Math.random();
                signDirection = isBritain ? -1 : 1;
                var group:FlxGroup = isWarning ? warnings : signs;
                var columns:int = isWarning ? 3 : 2;
                var spawn:Function = isWarning ? spawnWarning : spawnTruck;
                sign = FlxSprite(group.getFirstAvailable());
                sign.x = FlxG.width;
                sign.y = FlxG.height / 8 - sign.height / 2;
                sign.revive();
                sign.solid = false;
                var row:int = Math.min(sign.frames - columns, distance * int(sign.frames / columns) / 256);
                sign.frame = columns * row + (isBritain ? 1 : 0);
                warningFrame = sign.frame + (isBritain ? 1 : 2);
                FlxG.log("sign row " + row + " frame " + sign.frame + " brit " + isBritain);
                sign.velocity.x = 0.5 * velocityX;
                spawnTimer.start(spawnTime, 1, spawn);
                signDistance += 10 + FlxG.random() * 2;
                // FlxG.log("signDistance " + signDistance);
            }
            else if (4 == distance % 5) {
                if (-640 < velocityX) {
                    setVelocityX(velocityX - 60);
                }
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
            updateHud();
            super.update();
        }

        private function updateHud():void
        {
            if ("play" == state) {
                scoreText.text = "DISTANCE " + FlxG.score.toString();
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
            spawnTimer.stop();
            progressTimer.stop();
        }
        
        private function collide(player:FlxObject, enemy:FlxObject):void
        {
            if ("play" == state) {
                Player(player).play("collide");
                if (enemy is Truck) {
                    Truck(enemy).play("collide");
                }
                enemy.x = player.x + player.width;
                stop();
                instructionText.text = "YOU CRASHED";
                FlxG.fade(0xFF000000, 3.0, lose);
                FlxG.camera.shake(0.05, 0.5, null, false, FlxCamera.SHAKE_HORIZONTAL_ONLY);
                state = "lose";
            }
        }

        private function setVelocityX(v:int):void
        {
            velocityX = v;
            for each (road in roads.members) {
                road.velocity.x = 0.5 * v;
            }
            for each (truck in enemies.members) {
                truck.velocity.x = 2 * v;
            }
            for each (warning in warnings.members) {
                warning.velocity.x = 0.5 * v;
            }
            for each (sign in signs.members) {
                sign.velocity.x = 0.5 * v;
            }
            spawnTime = baseSpawnTime * baseVelocityX / Math.min(-0.0625, v);
            progressTime = baseProgressTime * baseVelocityX / Math.min( -0.0625, v);
            // FlxG.log("setVelocityX: spawn " + spawnTime + " progress " + progressTime);
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
                    FlxG.timeScale = 2.0;
                }
                else if (FlxG.keys.justPressed("THREE")) {
                    FlxG.timeScale = 4.0;
                }
            }
        }
    }
}