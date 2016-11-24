package
{

import flash.display.Sprite;
import flash.media.Sound;
import flash.media.SoundChannel;

[SWF(width="800", height="600", frameRate="60", backgroundColor="#000000")]
public class Main extends Sprite
{
    public function Main()
    {
        GameStateModel.getInstance().init();
        var musicMain:Sound = new MusicMain();
        var musicSoundChannel:SoundChannel = musicMain.play(0, 1000);
        var gamefield: Gamefield = new Gamefield();
        addChild(gamefield);
    }
}
}
