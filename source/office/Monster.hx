class Monster{
    public var type:String;
    public  var aiLevel:Int;

    public var attackTimer:Float = 0;
    public var attackTime:Float;
    public var attackReady:Bool = false;

    public var curStage:Int = 0;
    function new(type:String, ?aiLevel:Int = 0) {
        this.type = type;
        this.aiLevel = aiLevel;
        this.attackTime = FlxG.random.float(25, 30) - aiLevel;
        trace(this.aiLevel + " + " + this.type);
    }
    public function tryMove():Bool
    {
        return FlxG.random.int(1, 20) <= aiLevel;
    }
}