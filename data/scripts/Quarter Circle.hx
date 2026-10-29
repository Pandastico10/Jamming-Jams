import flixel.util.FlxSpriteUtil;

function create() {}
function update(elapsed:Float) {}

function measureHit(curMeasure:Int) {
	if (active) {
		if (curStage >= 4) {
			level.backgroundTop.alpha = 1;
			FlxSpriteUtil.fadeOut(level.backgroundTop, 0.4);
		}

		if (curStage < 7 || curStage > 9) {
			level.shootCannon("normal", player);
		}

		level.shootCannon("fast", player);
		level.shootCannon("door", player);
	}
}

function beatHit(curBeat:Int) {
	if (active) {
		if (curStage <= 5) {
			if (curBeat % 4 != 0)
				return;
		} else {
			if (curBeat % 2 != 0)
				return;
		}

		level.shootCannon("down", player);
		level.shootCannon("left", player);
		level.shootCannon("right", player);
		level.shootCannon("up", player);
		camGame.zoom += 0.02;

		if (curStage >= 9 && curStage <= 11)
			level.backgroundTop.color = FlxG.random.color();
	}
}

function stepHit(curStep:Int) {
	if (active) {
		if (curStage >= 7 && curStep % 8 == 0) {
			if (curStage <= 9) {
				level.shootCannon("normal", player);
				level.backgroundTop.alpha = 1;
			}
			FlxSpriteUtil.fadeOut(level.backgroundTop, 0.4);
		}
	}
}

function nextStage() {
	if (curStage == 3)
		CoolUtil.playMusic(Paths.music('qc2'), true, 0.8, true, 130);
	else if (curStage == 5)
		CoolUtil.playMusic(Paths.music('qc3'), true, 0.8, true, 130);
	else if (curStage == 7)
		CoolUtil.playMusic(Paths.music('qc4'), true, 0.8, true, 130);
	else if (curStage == 9)
		CoolUtil.playMusic(Paths.music('qc5'), true, 0.8, true, 130);
}
