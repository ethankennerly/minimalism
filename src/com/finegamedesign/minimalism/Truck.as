package com.finegamedesign.minimalism
{
    import org.flixel.*;

    public class Truck extends FlxSprite
    {
        internal var sound:Boolean;

        public function Truck(X:int = 0, Y:int = 0, ImgClass:Class = null) 
        {
            super(X, Y, Sign.Img);
            loadGraphic(Sign.Img, true, false, 628 / 4, 81, true);
            width = 0.25 * frameWidth;
            // addAnimation("collide", [0], 30, true);
            // addAnimation("idle", [1], 30, true);
            // play("idle");
        }
        
        override public function update():void 
        {
            if (x < -frameWidth) {
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
