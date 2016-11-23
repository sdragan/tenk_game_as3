package
{

import flash.display.Sprite;

[SWF(width="640", height="480", frameRate="60", backgroundColor="#000000")]
public class Main extends Sprite
{
    public function Main()
    {
        var gamefield: Gamefield = new Gamefield();
        addChild(gamefield);
    }
}
}
