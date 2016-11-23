package
{
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.MouseEvent;

public class PreLevelMenu extends Sprite
{
    private var appearance:MenuPre_appearance;
    private var callback:Function;
    private var playButton:SimpleButton;

    public function PreLevelMenu(callback:Function)
    {
        this.callback = callback;
        appearance = new MenuPre_appearance();
        addChild(appearance);

        playButton = appearance.btn_Play;
        playButton.addEventListener(MouseEvent.CLICK, onPlayButton);
    }

    private function onPlayButton(event:MouseEvent):void
    {
        playButton.removeEventListener(MouseEvent.CLICK, onPlayButton);
        this.parent.removeChild(this);
        callback();
    }
}
}
