package
{
import com.greensock.TweenLite;
import com.greensock.easing.Back;

import flash.display.MovieClip;
import flash.display.Sprite;
import flash.geom.Rectangle;

public class CharacterView extends Sprite
{
    private var rect:Rectangle;
    private var deathCallback:Function;
    private var appearanceNormal:MovieClip;
    private var appearanceDead:MovieClip

    public function CharacterView(rect:Rectangle)
    {
        this.rect = rect;
        appearanceNormal = new CharacterNormal_appearance();
        appearanceDead = new CharacterDead_appearance();
        addChild(appearanceNormal);
        addChild(appearanceDead);
        appearanceDead.visible = false;
        appearanceNormal.visible = true;
        appearanceNormal.play();
    }

    public function update():void
    {
        this.x = rect.x;
        this.y = rect.y;
    }

    public function displayDeath(callback:Function):void
    {
        deathCallback = callback;
        appearanceNormal.stop();
        appearanceNormal.visible = false;
        appearanceDead.visible = true;
        deathStartFalling();
    }

    private function deathStartFalling():void
    {
        TweenLite.to(this, 1, {y: this.y + Constants.SCREEN_HEIGHT, ease: Back.easeIn, onComplete: deathFallFinished});
    }

    private function deathFallFinished():void
    {
        deathCallback();
    }

    public function reset():void
    {
        appearanceDead.visible = false;
        appearanceNormal.visible = true;
        appearanceNormal.play();
    }
}
}
