package
{
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.ui.Keyboard;

public class PostLevelMenu extends Sprite
{
    private var callback:Function;
    private var appearance:MenuPost_appearance;
    private var replayButton:SimpleButton;

    public function PostLevelMenu(callback:Function, score:int, scoreBest:int)
    {
        this.callback = callback;
        appearance = new MenuPost_appearance();
        addChild(appearance);

        appearance.txt_Score.text = "Score: " + score.toString();
        appearance.txt_ScoreBest.text = "Best: " + scoreBest.toString();
        replayButton = appearance.btn_Replay;
        addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
    }

    private function onAddedToStage(event:Event):void
    {
        removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        replayButton.addEventListener(MouseEvent.CLICK, onReplayButton);
        stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
    }

    private function onKeyDown(event:KeyboardEvent):void
    {
        if (event.keyCode == Keyboard.SPACE)
        {
            replay();
        }
    }

    private function onReplayButton(event:MouseEvent):void
    {
        replay();
    }

    private function replay():void
    {
        stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
        replayButton.removeEventListener(MouseEvent.CLICK, onReplayButton);
        this.parent.removeChild(this);
        callback();
    }
}
}
