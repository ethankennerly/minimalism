package com.finegamedesign.minimalism
{
    import org.flixel.*;
    
    public class MenuState extends FlxState
    {
        public static var textColor:uint = 0x000000;

        override public function create():void
        {
            super.create();
            FlxG.stage.frameRate = 60;
            FlxG.bgColor = 0xFFFFFF00;
            if (null == FlxG.scores || FlxG.scores.length <= 0) {
                FlxG.scores = [0];
                FlxG.score = 0;
            }
            else {
                FlxG.scores.push(FlxG.score);
            }
            var t:FlxText;
            t = new FlxText(0,FlxG.height/5,FlxG.width,"Right Side of the Road");
            t.size = 20;
            t.color = textColor;
            t.alignment = "center";
            add(t);
            t = new FlxText(0,FlxG.height/3, FlxG.width,
                "In BRITAIN, drive on the LEFT."
                + "\nIn USA, drive on the RIGHT."
                + "\nTo switch sides of the road, CLICK or press SPACE."
                + "\nTo start, CLICK or press SPACE."
                + "\n\nScore " + FlxG.score
                + "\nHigh Score " + Math.max.apply(null, FlxG.scores)
                );
            t.color = textColor;
            t.size = 14;
            t.alignment = "center";
            add(t);
        }

        override public function update():void
        {
            super.update();

            if(FlxG.mouse.justReleased() || FlxG.keys.justReleased("SPACE") || FlxG.keys.justPressed("X"))
            {
                FlxG.switchState(new PlayState());
            }
        }
    }
}
