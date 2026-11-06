import flixel.util.FlxSpriteUtil;

// mostly used for bg stuff only and specific events

function create() {
    if (FlxG.save.data.playerAbility == 'none')
		player.ability = 'jump';

}

function update(elapsed:Float) {}

function nextStage() {
    trace("you on the next stage");
}

function measureHit(curMeasure:Int) {
    if (active) {
        level.backgroundTop.alpha = 1;
        FlxSpriteUtil.fadeOut(level.backgroundTop, 0.5);
        level.shootCannon("normal", player);
        level.shootCannon("fast", player);
        level.shootCannon("door", player);
        camGame.zoom += 0.02;
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
        if (curStep % 4 != 0)
            return;

        level.shootCannon("rotate", player);
    }
}

function levelComplete() {}
