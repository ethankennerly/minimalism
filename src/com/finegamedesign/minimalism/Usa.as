package com.finegamedesign.minimalism
{
    import org.flixel.*;

    public class Usa extends FlxSprite
    {
        [Embed(source="../../../../gfx/usa.png")] internal static var Img:Class;

        public function Usa(X:int = 0, Y:int = 0, ImgClass:Class = null) 
        {
            super(X, Y, Img);
            solid = false;
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
