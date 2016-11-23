package {
public class CharacterView extends Sprite {
    private var rect:Rectangle;
    private var appearance:Sprite;
    private var deathCallback:Function;
    private var appearanceDefault:Sprite;

    public function CharacterView(rect:Rectangle, appearance:Sprite) {
        this.rect = rect;
        this.appearance = appearance;
        this.appearanceDefault = appearance;
        this.addChild(appearance);
        appearance.x = 0;
        appearance.y = 0;
//        appearance.play();
    }

    public function update():void {
        this.x = rect.x;
        this.y = rect.y;
    }

    public function displayDeath(callback:Function):void {
        deathCallback = callback;
        removeChild(appearance);
        appearance = new Sprite();  // dead character here
        deathStartFalling();

    }

    private function deathStartFalling():void {
        // TweenLite.to(3, {y: Constants.SCREEN_HEIGHT + 50});
    }

    private function deathFallFinished():void {
        deathCallback();
    }

    public function reset():void {
        removeChild(appearance);
        appearance = appearanceDefault;
        addChild(appearance);
//        appearance.play();
    }
}
}
