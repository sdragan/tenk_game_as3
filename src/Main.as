package
{

import flash.display.Sprite;

[SWF(width="800", height="600", frameRate="60", backgroundColor="#000000")]
public class Main extends Sprite
{
    public function Main()
    {
        GameStateModel.getInstance().init();
        var gamefield: Gamefield = new Gamefield();
        addChild(gamefield);
    }
}
}
