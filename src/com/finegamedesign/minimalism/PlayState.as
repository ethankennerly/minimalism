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
        private var driftTimer:FlxTimer;

        override public function create():void
        {
            FlxG.score = 0;
            // FlxG.visualDebug = true;
            super.create();
            driftTimer = new FlxTimer();
            enemies = new FlxGroup();
            direction = -1;
            player = new Player(40, middleY + direction * driftDistance);
            add(player);
            addGibs();
            addHud();
            state = "play";
            FlxG.camera.x = 0;
            FlxG.camera.y = 0;
        }

        /**
         * Player drifts to other side.
         */
        private function switchLane():void
        {
            direction = -direction;
            targetY = middleY + direction * driftDistance;
            player.velocity.y = 2 * direction * driftDistance * (1.0 / driftTime);
            FlxG.log("switchLane: at " + player.velocity.y + " to " + targetY);
            driftTimer.start(driftTime, 1, drift);
        }

        private function drift(timer:FlxTimer):void
        {
            player.velocity.y = 0;
            player.y = targetY;
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
            scoreText = new FlxText(FlxG.width - 40, 0, 100, "");
            scoreText.color = MenuState.textColor;
            scoreText.scrollFactor.x = 0.0;
            scoreText.scrollFactor.y = 0.0;
            add(scoreText);
        }

		override public function update():void 
        {
            updateInput();
            FlxG.overlap(player, enemies, collide);
            updateHud();
            super.update();
        }

        private function updateHud():void
        {
            if ("play" == state) {
                scoreText.text = "SCORE " + FlxG.score.toString();
                if (false) {
                    state = "lose";
                    instructionText.text = "YOU LOST";
                    FlxG.fade(0xFF000000, 3.0, lose);
                }
                else if (false) {
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
