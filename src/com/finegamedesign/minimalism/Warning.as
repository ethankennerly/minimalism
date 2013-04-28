package com.finegamedesign.minimalism
{
    import org.flixel.*;

    public class Warning extends FlxSprite
    {
        [Embed(source="../../../../gfx/warnings.png")] internal static var Img:Class;

        internal static var gas:int;
        internal static var outOfGas:Function;
        
        public function Warning(X:int = 0, Y:int = 0, ImgClass:Class = null) 
        {
            super(X, Y, Img);
            loadGraphic(Img, true, false, 634 / 3, 488 / 6, true);
            solid = false;
            gas = frames - 1;
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
