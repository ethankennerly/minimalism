package com.finegamedesign.minimalism
{
    import flash.display.Bitmap;
    import org.flixel.*;

    public class Warning extends FlxSprite
    {
        [Embed(source="../../../../gfx/warnings.png")] internal static var Img:Class;

        internal static var gas:int;
        internal static var fuelUp:Function;
        
        public function Warning(X:int = 0, Y:int = 0, ImgClass:Class = null) 
        {
            super(X, Y, Img);
            loadGraphic(Img, true, false, 630 / 3, 81, true);
            solid = false;
            gas = frames - 1;
            FlxG.log("Warning " + frames);
        }
        
        override public function update():void 
        {
            if (x < -width) {
                if (solid && gas == frame) {
                    flicker();
                    solid = false;
                    fuelUp();
                }
                kill();
            }
            super.update();
        }
    }
}
