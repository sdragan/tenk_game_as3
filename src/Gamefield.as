package
{
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.ui.Keyboard;

public class Gamefield extends Sprite
{
    private var characterRect:Rectangle;
    private var characterView:CharacterView;
    private var characterSpeedY:Number;
    private var obstacles:Vector.<Vector.<Rectangle>>;
    private var obstacleViews:Vector.<ObstacleView>;
    private var gameState:int;
    private var score:int;
    private var scoreHUD:ScoreHUD;
    private var distanceUntilScoreIncreased:Number;
    private var bg:Sprite;
    private var fgParts:Vector.<Sprite>;

    private const SCROLL_SPEED:Number = 160;
    private const TOP_BORDER:int = 0;
    private const BOTTOM_BORDER:int = 52;
    private const OBSTACLE_MIN_OFFSET_Y:int = 50;
    private const OBSTACLES_SPACING_HORIZONTAL:int = 200;
    private const OBSTACLES_SPACING_VERTICAL:int = 150;
    private const OBSTACLE_WIDTH:int = 156;
    private const OBSTACLE_HEIGHT:int = 600;
    private const FG_WIDTH:int = 800;
    private const OBSTACLES_SHIFT_VALUE:int = Constants.SCREEN_WIDTH * 1.5;
    private const GRAVITY:Number = 360;
    private const CHARACTER_INITIAL_X:int = 80;
    private const CHARACTER_INITIAL_Y:int = Constants.SCREEN_HEIGHT / 2.5;
    private const CHARACTER_SIZE:int = 30;
    private const CHARACTER_MAX_FALLING_SPEED_Y:Number = -300;
    private const CHARACTER_JUMP_SPEED:Number = 220;

    private const GAMESTATE_MENU_PRE:int = 0;
    private const GAMESTATE_NORMAL:int = 1;
    private const GAMESTATE_LOST:int = 2;
    private const GAMESTATE_MENU_POST:int = 3;

    public function Gamefield()
    {
        score = 0;
        distanceUntilScoreIncreased = OBSTACLES_SHIFT_VALUE - CHARACTER_INITIAL_X;
        initBg();
        initObstacles();
        initFg();
        initCharacter();
        gameState = GAMESTATE_MENU_PRE;
        var menuPre:PreLevelMenu = new PreLevelMenu(start);
        addChild(menuPre);
        addEventListener(Event.ENTER_FRAME, onEnterFrame);
    }

    private function start():void
    {
        initScoreHud();
        addInputListeners();
        gameState = GAMESTATE_NORMAL;
    }

    private function initScoreHud():void
    {
        scoreHUD = new ScoreHUD();
        scoreHUD.x = Constants.SCREEN_WIDTH / 2;
        scoreHUD.y = 50;
        scoreHUD.txt_Score.text = "0";
        addChild(scoreHUD);
    }

    private function initBg():void
    {
        bg = new Bg_appearance();
        addChild(bg);
    }

    private function initFg():void
    {
        fgParts = new <Sprite>[];
        for (var i:int = 0; i < 3; i++)
        {
            var fgPart:Sprite = new FgGround_appearance();
            fgPart.x = i * FG_WIDTH;
            fgPart.y = Constants.SCREEN_HEIGHT - fgPart.height;
            addChild(fgPart);
            fgParts.push(fgPart);
        }
    }

    private function scrollFg(dt:Number):void
    {
        var i:int;
        for (i = 0; i < fgParts.length; i++)
        {
            fgParts[i].x -= SCROLL_SPEED * dt;
        }

        for (i = 0; i < fgParts.length; i++)
        {
            if (fgParts[i].x <= -FG_WIDTH)
            {
                fgParts[i].x = getFgRightmostPoint();
            }
        }
    }

    private function getFgRightmostPoint():Number
    {
        var coordX:Number = 0;
        for (var i:int = 0; i < fgParts.length; i++)
        {
            if (fgParts[i].x > coordX)
            {
                coordX = fgParts[i].x;
            }
        }
        return coordX + FG_WIDTH;
    }

    private function addInputListeners():void
    {
        addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
        stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
    }

    private function removeInputListeners():void
    {
        removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
        stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
    }

    private function onKeyDown(event:KeyboardEvent):void
    {
        if (event.keyCode == Keyboard.SPACE)
        {
            jump();
        }
    }

    private function onMouseDown(event:MouseEvent):void
    {
        jump();
    }

    private function initCharacter():void
    {
        characterSpeedY = 0;
        characterRect = new Rectangle(CHARACTER_INITIAL_X, CHARACTER_INITIAL_Y, CHARACTER_SIZE, CHARACTER_SIZE);
        characterView = new CharacterView(characterRect);
        addChild(characterView);
        characterView.update();
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
            positionObstaclePair(obstaclePair, getNextGapY());

            obstacles.push(obstaclePair);

            var obstacleTopSprite:Sprite = new ObstacleTop_appearance();
            var obstacleTopView:ObstacleView = new ObstacleView(obstacleTop, obstacleTopSprite);
            var obstacleBottomSprite:Sprite = new ObstacleBottom_appearance();
            var obstacleBottomView:ObstacleView = new ObstacleView(obstacleBottom, obstacleBottomSprite);
            addChild(obstacleTopView);
            addChild(obstacleBottomView);
            obstacleTopView.update();
            obstacleBottomView.update();
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
                scrollFg(dt);
                break;
            case GAMESTATE_NORMAL:
                updateCharacter(dt);
                updateObstacles(dt);
                scrollFg(dt);
                updateScore(dt);
                checkCollision();
                break;
            case GAMESTATE_LOST:
                break;
            case GAMESTATE_MENU_POST:
                break;
        }
    }

    private function updateScore(dt:Number):void
    {
        distanceUntilScoreIncreased -= SCROLL_SPEED * dt;
        if (distanceUntilScoreIncreased <= 0)
        {
            score++;
            distanceUntilScoreIncreased = OBSTACLES_SPACING_HORIZONTAL + OBSTACLE_WIDTH;
            scoreHUD.txt_Score.text = score.toString();
        }
    }

    private function checkCollision():void
    {
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

    private function processObstacleHit():void
    {
        gameState = GAMESTATE_LOST;
        removeInputListeners();
        scoreHUD.visible = false;
        characterView.displayDeath(onDeathAnimationFinished);
    }

    private function onDeathAnimationFinished():void
    {
        if (score > GameStateModel.getInstance().getBestScore())
        {
            GameStateModel.getInstance().setBestScore(score);
        }
        var postMenu:PostLevelMenu = new PostLevelMenu(restart, score, GameStateModel.getInstance().getBestScore());
        addChild(postMenu);
    }

    private function restart():void
    {
        var shiftValue:int = OBSTACLES_SHIFT_VALUE - getLeftmostX();

        for (var i:int = 0; i < obstacles.length; i++)
        {
            obstacles[i][0].x += shiftValue;
            obstacles[i][1].x += shiftValue;
        }

        characterRect.x = CHARACTER_INITIAL_X;
        characterRect.y = CHARACTER_INITIAL_Y;

        characterView.reset();
        score = 0;
        distanceUntilScoreIncreased = OBSTACLES_SHIFT_VALUE;
        scoreHUD.txt_Score.text = "0";
        scoreHUD.visible = true;
        addInputListeners();
        gameState = GAMESTATE_NORMAL;
    }

    private function jump():void
    {
        characterSpeedY = CHARACTER_JUMP_SPEED;
    }

    private function updateCharacter(dt:Number):void
    {
        characterSpeedY -= GRAVITY * dt;
        if (characterSpeedY < CHARACTER_MAX_FALLING_SPEED_Y)
        {
            characterSpeedY = CHARACTER_MAX_FALLING_SPEED_Y;
        }
        characterRect.y -= characterSpeedY * dt;
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
        var activeZone:int = Constants.SCREEN_HEIGHT - TOP_BORDER - BOTTOM_BORDER - OBSTACLES_SPACING_VERTICAL - (OBSTACLE_MIN_OFFSET_Y * 2);
        var newGapY:int = (Math.random() * activeZone) + TOP_BORDER + OBSTACLE_MIN_OFFSET_Y;
        return newGapY;
    }

    private function getRightmostX():int
    {
        return getRightmostPair()[0].x;
    }

    private function getLeftmostX():int
    {
        return getLeftmostPair()[0].x;
    }

    private function getRightmostGapY():int
    {
        return getRightmostPair()[0].y + OBSTACLE_HEIGHT;
    }

    private function getLeftmostPair():Vector.<Rectangle>
    {
        var leftmostPair:Vector.<Rectangle> = obstacles[0];
        for (var i:int = 0; i < obstacles.length; i++)
        {
            if (obstacles[i][0].x < leftmostPair[0].x)
            {
                leftmostPair = obstacles[i];
            }
        }
        return leftmostPair;
    }

    private function getRightmostPair():Vector.<Rectangle>
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
}
}
