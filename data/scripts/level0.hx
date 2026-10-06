// mostly used for bg stuff only and specific events
function create() {}
function update(elapsed:Float) {}
function nextStage(curStage:Int) {}

function measureHit(curMeasure:Int) {
	level.shootCannon("normal", player);
	level.shootCannon("fast", player);
	level.shootCannon("door", player);
}

function beatHit(curBeat:Int) {
	if (curBeat % 2 != 0)
		return;

	level.shootCannon("down", player);
	level.shootCannon("left", player);
	level.shootCannon("right", player);
	level.shootCannon("up", player);
}

function stepHit(curStep:Int) {
	if (curStep % 4 != 0)
		return;

	level.shootCannon("rotate", player);
}

function death() {}
