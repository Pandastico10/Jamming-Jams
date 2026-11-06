import flixel.util.FlxSpriteUtil;

// mostly used for bg stuff only and specific events

function create() {

}

function update(elapsed:Float) {}

function nextStage() {
    if(curStage == 1){
        player.ability = 'time';
        player.applyAbility();
    }
    else if(curStage == 3){
        player.ability = 'dash';
        player.applyAbility();
    }
    else if(curStage == 5){
        player.ability = 'gravity';
        player.applyAbility();
    }
    else if(curStage == 7){
        player.ability = 'immunity';
        player.applyAbility();
    }
}

function measureHit(curMeasure:Int) {
    if (active) {
        level.backgroundTop.alpha = 1;
        FlxSpriteUtil.fadeOut(level.backgroundTop, 0.5);
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
		if (curStep % 8 != 0)
			return;
		level.shootCannon("rotate", player);
		camGame.zoom += 0.01;
	}
}

function levelComplete() {}
