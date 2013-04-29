package com.finegamedesign.minimalism
{
    import org.flixel.*;

    public class Sign extends FlxSprite
    {
        [Embed(source="../../../../gfx/signs.png")] internal static var Img:Class;

        public function Sign(X:int = 0, Y:int = 0, ImgClass:Class = null) 
        {
            super(X, Y, Img);
            loadGraphic(Img, true, false, 628 / 4, 81, true);
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
