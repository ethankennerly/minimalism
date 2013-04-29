package com.finegamedesign.minimalism
{
    import org.flixel.*;

    public class Truck extends FlxSprite
    {
        [Embed(source = "../../../../gfx/truck.png")] internal static var Img:Class;
        internal var sound:Boolean;

        public function Truck(X:int = 0, Y:int = 0, ImgClass:Class = null) 
        {
            super(X, Y, Img);
            loadGraphic(Img, true, false, 168, 84, true);
            addAnimation("collide", [0], 30, true);
            addAnimation("idle", [1], 30, true);
            play("idle");
        }
        
        override public function update():void 
        {
            if (x < -width) {
                sound = false;
                kill();
            }
            else if (solid && alive && x < 640 && sound) {
                sound = false;
                FlxG.play(Sounds.truck);
            }
            super.update();
        }
    }
}
