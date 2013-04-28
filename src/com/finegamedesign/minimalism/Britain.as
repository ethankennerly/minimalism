package com.finegamedesign.minimalism
{
    import org.flixel.*;

    public class Britain extends FlxSprite
    {
        [Embed(source="../../../../gfx/britain.png")] internal static var Img:Class;

        public function Britain(X:int = 0, Y:int = 0, ImgClass:Class = null) 
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
