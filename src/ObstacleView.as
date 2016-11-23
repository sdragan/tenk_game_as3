package
{
import flash.display.Sprite;
import flash.geom.Rectangle;

public class ObstacleView extends Sprite
{
    private var appearance: Sprite;
    private var rect:Rectangle;

    public function ObstacleView(rect:Rectangle, appearance: Sprite)
    {
        this.rect = rect;
        this.appearance = appearance;
        this.addChild(appearance);
    }

    public function update():void {
        this.x = rect.x;
        this.y = rect.y;

        trace(x, y);
    }
}
}
