import flixel.util.FlxSpriteUtil;
// mostly used for bg stuff only and specific events

function create() {}
function update(elapsed:Float) {}
function nextStage(curStage:Int) {}

function measureHit(curMeasure:Int) {
	if (active) {
        level.backgroundTop.alpha = 1;
		FlxSpriteUtil.fadeOut(level.backgroundTop, 1.5);
		level.shootCannon("normal", player);
		level.shootCannon("fast", player);
		level.shootCannon("door", player);
	}
}

function beatHit(curBeat:Int) {
	if (active) {
        if (curBeat % 2 != 0)
				return;
		level.shootCannon("down", player);
		level.shootCannon("left", player);
		level.shootCannon("right", player);
		level.shootCannon("up", player);
	}
}

function stepHit(curStep:Int) {
	if (active) {
		level.shootCannon("rotate", player);
	}
}

function death() {}
function nextStage() {}
