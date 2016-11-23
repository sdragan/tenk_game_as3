package
{
import flash.net.SharedObject;

public class GameStateModel
{
    private static var _instance:GameStateModel;

    private var sharedObject:SharedObject;
    private var bestScore:int = 0;

    private static const SHARED_OBJECT_NAME:String = "FlappyTenkTheGame";

    public function GameStateModel()
    {
    }

    public function init():void
    {
        sharedObject = SharedObject.getLocal(SHARED_OBJECT_NAME);
//        sharedObject.clear();
        if (sharedObject.data.bestScore == undefined)
        {
            sharedObject.data.bestScore = 0;
        }
        else
        {
            bestScore = sharedObject.data.bestScore;
        }
    }

    public function getBestScore():int
    {
        return bestScore;
    }

    public function setBestScore(value:int):void
    {
        bestScore = value;
        sharedObject.data.bestScore = bestScore;
        sharedObject.close();
    }

    public static function getInstance():GameStateModel
    {
        if (_instance == null)
        {
            _instance = new GameStateModel();
        }
        return _instance;
    }
}
}
