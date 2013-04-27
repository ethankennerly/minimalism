package com.finegamedesign.minimalism
{
    import org.flixel.*;
    [SWF(width="640", height="480", backgroundColor="#000000")]
    [Frame(factoryClass="Preloader")]

    public class Minimal extends FlxGame
    {
        public function Minimal()
        {
            super(640, 480, MenuState, 1);
        }
    }
}
