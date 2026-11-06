// mostly used for bg stuff only and specific events
import flixel.util.FlxSpriteUtil;

function create() {
	if (FlxG.save.data.playerAbility == 'none')
		player.ability = 'dash';
}

function update(elapsed:Float) {}

function measureHit(curMeasure:Int) {
	level.backgroundTop.alpha = 1;
	FlxSpriteUtil.fadeOut(level.backgroundTop, 0.4);
	if (active) {
		level.shootCannon("normal", player);
		level.shootCannon("fast", player);
		level.shootCannon("door", player);
	}
}

function beatHit(curBeat:Int) {
	if (active) {
		if (curBeat % 2 != 0)
			return;
		level.shootCannon("rotate", player);
		level.shootCannon("down", player);
		level.shootCannon("left", player);
		level.shootCannon("right", player);
		level.shootCannon("up", player);
	}
}

function stepHit(curStep:Int) {}

function nextStage() {
	if (data.isStoryMode)
		if (curStage == 2) {
			gameOn();
			canSwitch = true;
		}
}

function levelComplete() {
	if (data.isStoryMode) {
		FlxG.save.data.beatlevel3 = true;
		FlxG.save.flush();
	}
}
