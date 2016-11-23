package {
public class PostLevelMenu extends Sprite {
    private var callback:Function;
    private var replayButton:SimpleButton;

    public function PostLevelMenu(callback: Function) {
        this.callback = callback;
        replayButton = new SimpleButton();
        addChild(replayButton);
        replayButton.addEventListener(MouseEvent.CLICK, onReplayButton);
    }

    private function onReplayButton(event:MouseEvent):void {
        replayButton.removeEventListener(MouseEvent.CLICK, onReplayButton);
        this.parent.removeChild(this);
        callback();
    }
}
}
