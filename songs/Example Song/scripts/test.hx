import platformer.Level;

var level:Level;

function create() {
	level = new Level("current");

	add(level.player);
	trace("ADDED PLAYER: " + level.player);
	trace("PLAYER X: " + level.player.x);
	trace("PLAYER Y: " + level.player.y);
	trace("PLAYER GRAPHIC: " + level.player.graphic);

	CoolUtil.playMusic(Paths.music(level.music), true, 0.8, true, level.bpm);
}

function update(elapsed:Float) {
	level.update(elapsed);
}

function beatHit(curBeat:Int) {
	level.beatHit(curBeat);
}

function stepHit(curStep:Int) {
	level.stepHit(curStep);
}
