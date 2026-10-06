import platformer.Level;
import platformer.Player;

public var level:Level;
public var player:Player;
var script:Script;
public var blend = new FlxSprite();
public var camGame:FlxCamera = new FlxCamera();
public var camBg:FlxCamera = new FlxCamera();

function create() {
	FlxG.cameras.add(camBg, false);
	blend.makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
	add(blend);
	blend.cameras = [camBg];
	FlxG.cameras.add(camGame, true);
	camGame.bgColor = 0;

	// load the level  name // assign cam
	level = new Level("current", camGame);

	add(level.cannons);
	add(level.boxes);
	add(level.eventBoxes);

	// add player
	player = new Player(level.playerX, level.playerY);

	player.maxJumpAmm = level.maxJumpAmm;
	player.jumpAmm = level.maxJumpAmm;
	add(player);
	player.test();

	for (path in Paths.getFolderContent("data/scripts/")) {
		if (Path.extension(path) == "hx" && Path.withoutExtension(path) == level.level) {
			script = importScript("data/scripts/" + level.level);
			break;
		}
	}

	if (level.levelWidth > 768) {
		camGame.setScrollBoundsRect(0, 0, level.levelWidth, camGame.height, true);
		camGame.follow(player);
		camGame.followLerp = 0.05;
	}

	CoolUtil.playMusic(Paths.music(level.music), true, 0.8, true, level.bpm);
}

function update(elapsed:Float) {
	FlxG.overlap(level.eventBoxes, player, nextStage);
	level.update(player);
}

function nextStage() {
	player.x = level.playerX;
	player.y = level.playerY;
	level.loadStage(level.curStage + 1);
}

function beatHit(curBeat:Int) {}
function stepHit(curStep:Int) {}
function measureHit(curMeasure:Int) {}