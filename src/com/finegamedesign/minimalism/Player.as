package com.finegamedesign.minimalism
{
    import org.flixel.*;

    public class Player extends FlxSprite
    {
        [Embed(source="../../../../gfx/car.png")] internal static var Img:Class;

        public function Player(X:int = 0, Y:int = 0, ImgClass:Class = null) 
        {
            super(X, Y, Img);
            drag.y = 0;
            acceleration.y = 0;
        }
    }
}
