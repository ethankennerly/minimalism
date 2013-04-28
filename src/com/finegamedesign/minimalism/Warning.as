package com.finegamedesign.minimalism
{
    import org.flixel.*;

    public class Warning extends FlxSprite
    {
        [Embed(source="../../../../gfx/warnings.png")] internal static var Img:Class;

        internal static var gas:int = 8;
        internal static var outOfGas:Function;
        
        public function Warning(X:int = 0, Y:int = 0, ImgClass:Class = null) 
        {
            super(X, Y, Img);
            loadGraphic(Img, true, false, 633 / 3, 244 / 3, true);
            solid = false;
        }
        
        override public function update():void 
        {
            if (x < -width) {
                if (solid && gas == frame) {
                    outOfGas();
                }
                kill();
            }
            super.update();
        }
    }
}
