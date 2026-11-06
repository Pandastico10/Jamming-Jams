import flixel.util.FlxSpriteUtil;

// mostly used for bg stuff only and specific events

function create() {
	if (FlxG.save.data.playerAbility == 'none')
		player.ability = 'immunity';
}

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
		level.shootCannon("rotate", player);
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
	if (comingBack) {
		if (curStage <= 3)
			CoolUtil.playMusic(Paths.music('lms1'), true, 0.8, true, 138);
		else if (curStage <= 5)
			CoolUtil.playMusic(Paths.music('lms2'), true, 0.8, true, 138);
		else if (curStage <= 7)
			CoolUtil.playMusic(Paths.music('lms3'), true, 0.8, true, 138);
		else if (curStage >= 9)
			CoolUtil.playMusic(Paths.music('lms4'), true, 0.8, true, 138);
	} else {
		if (curStage == 3)
			CoolUtil.playMusic(Paths.music('lms1'), true, 0.8, true, 138);
		else if (curStage == 5)
			CoolUtil.playMusic(Paths.music('lms2'), true, 0.8, true, 138);
		else if (curStage == 7)
			CoolUtil.playMusic(Paths.music('lms3'), true, 0.8, true, 138);
		else if (curStage == 9)
			CoolUtil.playMusic(Paths.music('lms4'), true, 0.8, true, 138);
	}
}

function levelComplete() {
	FlxG.save.data.beatlevel5 = true;
	FlxG.save.data.editorUnlocked = true;
	FlxG.save.flush();
}
