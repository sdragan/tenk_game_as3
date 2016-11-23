package
{
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Rectangle;

public class Gamefield extends Sprite
{
    private var characterRect:Rectangle;
    private var characterView:CharacterView;
    private var characterSpeedY:Number;
    private var obstacles:Vector.<Vector.<Rectangle>>;
    private var obstacleViews:Vector.<ObstacleView>;
    private var gameState:int;
    private var score:int;
    private var distanceUntilScoreIncreased:int;

    private const SCROLL_SPEED:Number = 30;
    private const TOP_BORDER:int = 0;
    private const BOTTOM_BORDER:int = 50;
    private const OBSTACLE_MIN_OFFSET_Y: int = 20;
    private const OBSTACLES_SPACING_HORIZONTAL:int = 160;
    private const OBSTACLES_SPACING_VERTICAL:int = 50;
    private const OBSTACLE_WIDTH:int = 50;
    private const OBSTACLE_HEIGHT:int = 500;
    private const OBSTACLES_SHIFT_VALUE:int = Constants.SCREEN_WIDTH * 1.5;
    private const GRAVITY:Number = 50;
    private const CHARACTER_INITIAL_X: int = 50;
    private const CHARACTER_INITIAL_Y: int = Constants.SCREEN_HEIGHT / 2;
    private const CHARACTER_SIZE:int = 20;
    private const CHARACTER_MAX_FALLING_SPEED_Y:Number = -40;
    private const CHARACTER_JUMP_SPEED:Number = 100;

    private const GAMESTATE_MENU_PRE: int = 0;
    private const GAMESTATE_NORMAL: int = 1;
    private const GAMESTATE_LOST: int = 2;
    private const GAMESTATE_MENU_POST: int = 3;

    public function Gamefield()
    {
        score = 0;
        distanceUntilScoreIncreased = OBSTACLES_SHIFT_VALUE;
        initCharacter();
        initObstacles();
        gameState = GAMESTATE_NORMAL;

        addEventListener(Event.ENTER_FRAME, onEnterFrame);
    }

    private function addInputListeners():void {
        addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
    }

    private function removeInputListeners():void {
        removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
    }

    private function onMouseDown(event:MouseEvent):void {
        jump();
    }

    private function initCharacter():void
    {
        characterSpeedY = 0;
        characterRect = new Rectangle(CHARACTER_INITIAL_X, CHARACTER_INITIAL_Y, CHARACTER_SIZE, CHARACTER_SIZE);
        var characterSprite:Sprite = createDebugSprite(characterRect);
        characterView = new CharacterView(characterRect, characterSprite);
        addChild(characterView);
    }

    private function initObstacles():void
    {
        obstacles = new <Vector.<Rectangle>>[];
        obstacleViews = new <ObstacleView>[];

        var amount:int = getObstaclesAmountHorizontal();
        for (var i:int = 0; i < amount; i++)
        {
            var obstaclePair:Vector.<Rectangle> = new <Rectangle>[];
            var obstacleX:int = i * (OBSTACLES_SPACING_HORIZONTAL + OBSTACLE_WIDTH) + OBSTACLES_SHIFT_VALUE;
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
        switch (gameState)
        {
            case GAMESTATE_MENU_PRE:
                break;
            case GAMESTATE_NORMAL:
                updateCharacter(dt);
                updateObstacles(dt);
                updateScore(dt);
                checkCollision();
                break;
            case GAMESTATE_LOST:
                break;
            case GAMESTATE_MENU_POST:
                break;
        }

    }

    private function updateScore(dt:Number):void {
        distanceUntilScoreIncreased -= SCROLL_SPEED * dt;
        if (distanceUntilScoreIncreased <= 0)
        {
            score ++;
            distanceUntilScoreIncreased = OBSTACLES_SPACING_HORIZONTAL + OBSTACLE_WIDTH;
        }
    }

    private function checkCollision():void {
        for each (var obstaclePair:Vector.<Rectangle> in obstacles)
        {
            if (characterRect.intersects(obstaclePair[0]) || characterRect.intersects(obstaclePair[1]))
            {
                processObstacleHit();
                return;
            }
        }

        if (characterRect.top < 0 || characterRect.bottom > (Constants.SCREEN_HEIGHT - BOTTOM_BORDER))
        {
            processObstacleHit();
        }
    }

    private function processObstacleHit():void {
        gameState = GAMESTATE_LOST;
        removeInputListeners();
        characterView.displayDeath(onDeathAnimationFinished);
    }

    private function onDeathAnimationFinished()
    {
        var postMenu: PostLevelMenu = new PostLevelMenu(restart);
        addChild(postMenu);
    }

    private function restart():void {
        for (var i:int = 0; i < obstacles.length; i++) {
            obstacles[i][0].x += OBSTACLES_SHIFT_VALUE;
            obstacles[i][1].x += OBSTACLES_SHIFT_VALUE;
        }

        characterRect.x = CHARACTER_INITIAL_X;
        characterRect.y = CHARACTER_INITIAL_Y;

        characterView.reset();
        score = 0;
        distanceUntilScoreIncreased = OBSTACLES_SHIFT_VALUE;
        gameState = GAMESTATE_MENU_POST;
    }

    private function jump():void {
        characterSpeedY = CHARACTER_JUMP_SPEED;
    }

    private function updateCharacter(dt:Number):void {
        characterSpeedY -= GRAVITY * dt;
        if (characterSpeedY < CHARACTER_MAX_FALLING_SPEED_Y)
        {
            characterSpeedY = CHARACTER_MAX_FALLING_SPEED_Y;
        }
        characterRect.y -= characterSpeedY;
        characterView.update();
    }

    private function updateObstacles(dt:Number):void
    {
        for each (var obstaclePair:Vector.<Rectangle> in obstacles)
        {
            obstaclePair[0].x -= SCROLL_SPEED * dt;
            obstaclePair[1].x -= SCROLL_SPEED * dt;
            if (obstaclePair[0].right < 0)
            {
                var newX:int = getRightmostX() + OBSTACLE_WIDTH + OBSTACLES_SPACING_HORIZONTAL;
                var newGapY:int = getNextGapY();

                obstaclePair[0].x = newX;
                obstaclePair[1].x = newX;
                positionObstaclePair(obstaclePair, newGapY);
            }
        }

        for each (var obstacleView:ObstacleView in obstacleViews)
        {
            obstacleView.update();
        }
    }

    private function getNextGapY():int
    {
        var activeZone = Constants.SCREEN_HEIGHT - TOP_BORDER - BOTTOM_BORDER - OBSTACLES_SPACING_VERTICAL - (OBSTACLE_MIN_OFFSET_Y * 2);
        var newGapY: int = Math.random() * activeZone + TOP_BORDER + OBSTACLE_MIN_OFFSET_Y;
        return newGapY;
    }

    private function getRightmostX():int
    {
        return getRightMostPair()[0].x;
    }

    private function getRightmostGapY():int
    {
        return getRightMostPair()[0].y + OBSTACLE_HEIGHT;
    }

    private function getRightMostPair():Vector.<Rectangle>
    {
        var rightmostPair:Vector.<Rectangle> = obstacles[0];
        for (var i:int = 0; i < obstacles.length; i++)
        {
            if (obstacles[i][0].x > rightmostPair[0].x)
            {
                rightmostPair = obstacles[i];
            }
        }
        return rightmostPair;
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
