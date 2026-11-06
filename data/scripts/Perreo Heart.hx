// mostly used for bg stuff only and specific events
import flixel.util.FlxSpriteUtil;

function create() {
	if (FlxG.save.data.playerAbility == 'none')
		player.ability = 'gravity';
}

function update(elapsed:Float) {}

function measureHit(curMeasure:Int) {
	if (active) {
		level.backgroundTop.alpha = 1;
		FlxSpriteUtil.fadeOut(level.backgroundTop, 0.4);
		level.shootCannon("normal", player);
		level.shootCannon("fast", player);
		level.shootCannon("door", player);
	}
}

function beatHit(curBeat:Int) {
	if (active) {
		if (curBeat % 4 != 0)
			return;
		
		level.shootCannon("down", player);
		level.shootCannon("left", player);
		level.shootCannon("right", player);
		level.shootCannon("up", player);
	}
}

function stepHit(curStep:Int) {
	if (active) {
		if (curStep % 8 != 0)
			return;
		level.shootCannon("rotate", player);
		camGame.zoom += 0.01;
	}
}

function nextStage() {}

function levelComplete() {
	if (data.isStoryMode) {
		FlxG.save.data.beatlevel4 = true;
		FlxG.save.flush();
	}
}
