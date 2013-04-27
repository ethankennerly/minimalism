package com.finegamedesign.minimalism
{
    import org.flixel.*;

    public class Road extends FlxSprite
    {
        [Embed(source="../../../../gfx/road.png")] internal static var Img:Class;

        public function Road(X:int = 0, Y:int = 0, ImgClass:Class = null) 
        {
            super(X, Y, Img);
            drag.y = 0;
            acceleration.y = 0;
        }
        
        override public function update():void 
        {
            if (x < -width) {
                x = FlxG.width + width - 2;
            }
            super.update();
        }
    }
}
