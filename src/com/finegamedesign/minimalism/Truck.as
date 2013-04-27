package com.finegamedesign.minimalism
{
    import org.flixel.*;

    public class Truck extends FlxSprite
    {
        [Embed(source="../../../../gfx/truck.png")] internal static var Img:Class;

        public function Truck(X:int = 0, Y:int = 0, ImgClass:Class = null) 
        {
            super(X, Y, Img);
            drag.y = 0;
            acceleration.y = 0;
        }
        
        override public function update():void 
        {
            if (x < -width) {
                kill();
            }
            super.update();
        }
    }
}
