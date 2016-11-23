package
{
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Rectangle;

public class Gamefield extends Sprite
{
    private var characterRect:Rectangle;
    private var characterSprite:Sprite;
    private var obstacles:Vector.<Vector.<Rectangle>>;
    private var obstacleViews:Vector.<ObstacleView>;

    private const SCROLL_SPEED:Number = 10;
    private const OBSTACLES_SPACING_HORIZONTAL:int = 160;
    private const OBSTACLES_SPACING_VERTICAL:int = 50;
    private const OBSTACLE_WIDTH:int = 50;
    private const OBSTACLE_HEIGHT:int = 500;

    public function Gamefield()
    {
//        initCharacter();
        initObstacles();

        addEventListener(Event.ENTER_FRAME, onEnterFrame);
    }

    private function initCharacter():void
    {
        characterRect = new Rectangle(100, 100, 100, 100);
        characterSprite = createDebugSprite(characterRect);
    }

    private function initObstacles():void
    {
        obstacles = new <Vector.<Rectangle>>[];
        obstacleViews = new <ObstacleView>[];

        var amount:int = getObstaclesAmountHorizontal();
        for (var i:int = 0; i < amount; i++)
        {
            var obstaclePair:Vector.<Rectangle> = new <Rectangle>[];
            var obstacleX:int = i * (OBSTACLES_SPACING_HORIZONTAL + OBSTACLE_WIDTH);
            var obstacleTop:Rectangle = new Rectangle(obstacleX, 0, OBSTACLE_WIDTH, OBSTACLE_HEIGHT);
            var obstacleBottom:Rectangle = new Rectangle(obstacleX, 0, OBSTACLE_WIDTH, OBSTACLE_HEIGHT);

            obstaclePair.push(obstacleTop);
            obstaclePair.push(obstacleBottom);
            positionObstaclePair(obstaclePair, 100 + Math.floor(Math.random() * 300));

            obstacles.push(obstaclePair);

            var obstacleTopSprite:Sprite = createDebugSprite(obstacleTop);
            var obstacleTopView:ObstacleView = new ObstacleView(obstacleTop, obstacleTopSprite);
            var obstacleBottomSprite:Sprite = createDebugSprite(obstacleBottom);
            var obstacleBottomView:ObstacleView = new ObstacleView(obstacleBottom, obstacleBottomSprite);
            addChild(obstacleTopView);
            addChild(obstacleBottomView);
            obstacleViews.push(obstacleTopView, obstacleBottomView);
        }
    }

    private function getObstaclesAmountHorizontal():Number
    {
        return Math.ceil(Constants.SCREEN_WIDTH / (OBSTACLE_WIDTH + OBSTACLES_SPACING_HORIZONTAL)) + 1;
    }

    private function positionObstaclePair(obstaclePair:Vector.<Rectangle>, gapY:int):void
    {
        var topObstacleY:int = gapY - OBSTACLE_HEIGHT;
        var bottomObstacleY:int = gapY + OBSTACLES_SPACING_VERTICAL;
        obstaclePair[0].y = topObstacleY;
        obstaclePair[1].y = bottomObstacleY;
    }

    private function onEnterFrame(event:Event):void
    {
        update(1 / Constants.FRAMERATE);
    }

    private function update(dt:Number):void
    {
        for each (var obstacleView:ObstacleView in obstacleViews)
        {
            obstacleView.update();
        }

//        scrollObstacles(dt);
    }

    private function scrollObstacles(dt:Number):void
    {
        for each (var obstaclePair:Vector.<Rectangle> in obstacles)
        {
            obstaclePair[0].x -= SCROLL_SPEED * dt;
            obstaclePair[1].x -= SCROLL_SPEED * dt;
            if (obstaclePair[0].right < 0)
            {
                var newX:int = getRightmostX() + OBSTACLE_WIDTH + OBSTACLES_SPACING_HORIZONTAL;
                trace("Placing at the right: " + newX);
                obstaclePair[0].x = newX;
                obstaclePair[1].x = newX;
                var newGapY:int = Math.floor(Math.random() * 300) + 100;
                positionObstaclePair(obstaclePair, newGapY);
            }
        }

        for each (var obstacleView:ObstacleView in obstacleViews)
        {
            obstacleView.update();
        }
    }

    private function getRightmostX():int
    {
        var rightmostX:int = 0;
        for (var i:int = 0; i < obstacles.length; i++)
        {
            if (obstacles[i][0].x > rightmostX)
            {
                rightmostX = obstacles[i][0].x;
            }
        }
        return rightmostX;
    }

    private function createDebugSprite(rect:Rectangle):Sprite
    {
        var sprite:Sprite = new Sprite();
        sprite.graphics.beginFill(0xFFFFFF * Math.random());
        sprite.graphics.drawRect(0, 0, rect.width, rect.height);
        sprite.graphics.endFill();
        sprite.x = rect.x;
        sprite.y = rect.y;
        addChild(sprite);
        return sprite;
    }
}
}
