package com.finegamedesign.minimalism
{
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
        private var driftTime:Number = 0.5;
        private var middleY:int = 240;
        private var targetY:int;
        private var direction:int;
        private var signDirection:int;
        private var driftTimer:FlxTimer;
        private var truck:Truck;
        private var velocityX:int = -160;
        private var road:Road;
        private var roads:FlxGroup;
        private var spawnTimer:FlxTimer;
        private var spawnTime:Number = 2.0;
        private var progressTimer:FlxTimer;
        private var progressTime:Number = 1.0;
        private var distance:int;

        override public function create():void
        {
            FlxG.score = 0;
            // FlxG.visualDebug = true;
            super.create();
            driftTimer = new FlxTimer();
            roads = new FlxGroup();
            road = new Road();
            var roadY:int = middleY - road.height / 2;
            for (var roadX:int = 0; roadX < FlxG.width + 2 * road.width; roadX += road.width - 2) {
                road = new Road(roadX, roadY);
                road.velocity.x = velocityX;
                roads.add(road);
            }
            add(roads);
            enemies = new FlxGroup();
            for (var concurrentTruck:int = 0; concurrentTruck < 2; concurrentTruck++) {
                truck = new Truck();
                truck.exists = false;
            }
            enemies.add(truck);
            spawnTimer = new FlxTimer();
            spawnTimer.start(spawnTime, 9, spawnTruck);
            progressTimer = new FlxTimer();
            progressTimer.start(progressTime, 9, progress);
            direction = 1;
            signDirection = 1;
            player = new Player(40, middleY + direction * driftDistance);
            add(player);
            addGibs();
            addHud();
            state = "play";
        }

        /**
         * Player drifts to other side.
         */
        private function switchLane():void
        {
            direction = -direction;
            targetY = middleY + direction * driftDistance;
            player.velocity.y = 2 * direction * driftDistance * (1.0 / driftTime);
            // FlxG.log("switchLane: at " + player.velocity.y + " to " + targetY);
            driftTimer.start(driftTime, 1, drift);
        }

        private function drift(timer:FlxTimer):void
        {
            player.velocity.y = 0;
            player.y = targetY;
        }
        
        private function spawnTruck(timer:FlxTimer):void
        {
            truck = Truck(enemies.getFirstAvailable());
            truck.revive();
            truck.y = middleY + -signDirection * driftDistance;
            truck.x = 640;
            truck.velocity.x = 2 * velocityX;
            add(truck);
        }
        
        private function progress(timer:FlxTimer):void
        {
            distance++;
            FlxG.score += 100;
        }
        
        private function addGibs():void
        {
            gibs = new FlxEmitter();
		    gibs.makeParticles(Player.Img, 50, 32, false, 0.5);
            gibs.gravity = 376;
            gibs.setRotation(0, 0);
            gibs.bounce = 0.25;
		    gibs.setXSpeed(-150, 150);
            gibs.particleDrag = new FlxPoint(50, 0);
            gibs.setSize(2, 2);
            add(gibs);
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
            enemies.update();
            FlxG.overlap(player, enemies, collide);
            updateHud();
            super.update();
        }

        private function updateHud():void
        {
            if ("play" == state) {
                scoreText.text = "DISTANCE " + FlxG.score.toString();
                if (player.health <= 0) {
                    state = "lose";
                    instructionText.text = "YOU LOST";
                    FlxG.fade(0xFF000000, 3.0, lose);
                }
                else if (10 <= distance) {
                    FlxG.score += 100;
                    instructionText.text = "YOU WON";
                    state = "win";
                    FlxG.fade(0xFFFFFFFF, 3.0, win);
                }
            }
        }

        private function lose():void
        {
            FlxG.switchState(new MenuState());
        }

        private function win():void
        {
            FlxG.switchState(new MenuState());
        }
   
        private function collide(player:FlxObject, enemy:FlxObject):void
        {
            player.hurt(1);
            enemy.hurt(1);
        }

        /**
         * Press SPACE, or click mouse.
         * To make it harder, play 2x speed: press Shift+2.  
         * To make it normal again, play 1x speed: press Shift+1.  
         */ 
        private function updateInput():void
        {
            if (FlxG.mouse.justPressed() || FlxG.keys.justPressed("SPACE") || FlxG.keys.justPressed("X")) {
                switchLane();
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
