package com.finegamedesign.minimalism
{
    import org.flixel.*;

    public class Warning extends FlxSprite
    {
        [Embed(source="../../../../gfx/warnings.png")] internal static var Img:Class;

        public function Warning(X:int = 0, Y:int = 0, ImgClass:Class = null) 
        {
            super(X, Y, Img);
            loadGraphic(Img, true, false, 633 / 3, 244 / 3, true);
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
