package com.finegamedesign.minimalism
{
    import org.flixel.*;

    public class Player extends FlxSprite
    {
        [Embed(source="../../../../gfx/player.png")] internal static var Img:Class;

        public function Player(X:int = 0, Y:int = 0, ImgClass:Class = null) 
        {
            super(X, Y, Img);
            // loadGraphics(playerImg,true,true,8);
        }

        override public function update():void
        {
            super.update();
        }
    }
}
