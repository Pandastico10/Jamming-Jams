// mostly used for bg stuff only and specific events
import flixel.util.FlxSpriteUtil;

typing.onStart.add(() -> {
	if (isOffice)
		room.gameon = true;
	
	blend.makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
	blend.alpha = 0;
	blend.cameras = [camHUD];
	insert(0, blend);
	FlxTween.tween(blend, {alpha: 0.75}, 2, {ease: FlxEase.cubeOut});
});
typing.onComplete.add(() -> {
	if (isOffice){
		room.gameon = false;
		drone.play();
	}
	active = true;
	player.test();
	FlxTween.tween(blend, {alpha: 0}, 1, {ease: FlxEase.cubeOut});
	FlxTween.tween(typing, {alpha: 0}, 1, {ease: FlxEase.cubeOut});
});
typing.onProgress.add(() -> {
	typing.screenCenter(); // re-centers the text to the screen on every new character typed.
});
function create() {
	active = false;
	// stop everything if dialogue exists aka this script
	player.test();
	// start dialogue + setup
	JamUtils.startDialogue(typing, "json/dialogue");
	add(typing);
	JamUtils.setupText(typing, 48, 'center', 'Outline.ttf');
	typing.cameras = [camHUD];
	typing.sounds = [FlxG.sound.load(Paths.sound("talk"))];
}

function update(elapsed:Float) {}
function nextStage(curStage:Int) {}

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
		if (curStep % 4 != 0)
			return;

		level.shootCannon("rotate", player);
	}
}

function death() {
	
}

function nextStage() {
	trace("you on the next stage");
}
