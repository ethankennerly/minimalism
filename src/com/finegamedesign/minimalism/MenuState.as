package com.finegamedesign.minimalism
{
    import org.flixel.*;
    
    public class MenuState extends FlxState
    {
        public static var textColor:uint = 0x000000;
        private var playing:Boolean;
        
        override public function create():void
        {
            super.create();
            FlxG.stage.frameRate = 60;
            FlxG.bgColor = 0xFFFFFF00;
            if (null == FlxG.scores || FlxG.scores.length <= 0) {
                FlxG.scores = [0];
                FlxG.score = 0;
                FlxG.playMusic(Sounds.music);
            }
            else {
                FlxG.scores.push(FlxG.score);
            }
            var t:FlxText;
            t = new FlxText(0,FlxG.height/8,FlxG.width,"Right Side of the Road");
            t.size = 20;
            t.color = textColor;
            t.alignment = "center";
            add(t);
            t = new FlxText(0,FlxG.height/5, FlxG.width,
                "In BRITAIN, drive on TOP."
                + "\nIn USA, drive on BOTTOM."
                + "\nTo switch sides, press SPACE or CLICK."
                + "\nTo start, CLICK anywhere."
                + "\n\nScore " + FlxG.score
                + "\nHigh Score " + Math.max.apply(null, FlxG.scores)
                + "\n\nWHITE sign:             BLACK warning:"
                +   "\nTheir lane.                 Your lane."
                );
            t.color = textColor;
            t.size = 14;
            t.alignment = "center";
            add(t);
            var sign:Sign = new Sign(320, 280);
            sign.x -= sign.frameWidth * 1.25;
            sign.frame = 5;
            add(sign);
            sign = new Sign(320, 380);
            sign.x -= sign.frameWidth * 1.25;
            sign.frame = 4;
            add(sign);
            var warning:Warning = new Warning(320, 280);
            warning.frame = 4;
            add(warning);
            warning = new Warning(320, 380);
            warning.frame = 5;
            add(warning);
            playing = false;
        }

        override public function update():void
        {
            super.update();

            if(FlxG.mouse.justReleased() || FlxG.keys.justReleased("SPACE") || FlxG.keys.justPressed("X"))
            {
                FlxG.play(Sounds.start);
                FlxG.fade(0xFFFFFF00, 0.5, play);
            }
        }
        
        private function play():void
        {
            if (!playing) {
                playing = true;
                FlxG.switchState(new PlayState());
            }
        }
    }
}
