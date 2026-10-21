import office.Monster;

var moveTimer:Float = 0;
var movementInterval:Float = 5.0;

class Manager {
	var monsters:Array<Monster>;

	function new(?leftAi:Int = 0, ?rightAi:Int = 0, ?backAi:Int = 0, ?upAi:Int = 0) {
		monsters = [];
        movementInterval = FlxG.random.float(25, 30) - (leftAi +  rightAi + backAi + upAi)/2;
        if (leftAi != 0)
		monsters.push(new Monster('left', leftAi));
        if (rightAi != 0)
		monsters.push(new Monster('right', rightAi));
        if (backAi != 0)
		monsters.push(new Monster('back', backAi));
        if (upAi != 0)
		monsters.push(new Monster('up', upAi));
	}
    public function update(elapsed:Float) {
        moveTimer += elapsed;

        if (moveTimer < movementInterval)
            return;

        moveTimer -= movementInterval;
        for (mon in monsters){
            if(mon.tryMove() && mon.type == "back"){
                mon.curStage++;
                mon.curStage = FlxMath.bound(mon.curStage, 0, 5);
                trace("back moved! to stage" + mon.curStage);
                FlxG.sound.play(Paths.sound('back'+mon.curStage));

            }
        }
    }
}
