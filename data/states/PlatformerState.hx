import platformer.Level;
import platformer.Player;
import FunkinTypeText;

public var level:Level;
public var player:Player;
var script:Script;
public var blend = new FlxSprite();
public var deathCounter:FlxText;
public var timeCounter:FlxText;
public var camGame:FlxCamera = new FlxCamera();
public var camBg:FlxCamera = new FlxCamera();
public var camHUD:FlxCamera = new FlxCamera();
public var typing:FunkinTypeText = new FunkinTypeText(0, 0, FlxG.width, 8);
public var isOffice:Bool = false;
public var active:Bool = true;
public var time:Float = 0;

// game shaders
var scanline = new CustomShader('scanline');

function create() {
	FlxG.cameras.add(camBg, false);
	blend.makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
	add(blend);
	blend.cameras = [camBg];
	FlxG.cameras.add(camGame, true);
	camGame.bgColor = 0;
	FlxG.cameras.add(camHUD, false);
	camHUD.bgColor = 0;

	if (FlxG.save.data.shaders) {
		camGame.addShader(scanline);
	}
	// load the level  name // assign cam
	level = new Level(data, camGame);
	add(level.backgroundSprites);
	add(level.cannons);
	add(level.boxes);
	add(level.eventBoxes);
	// add player
	player = new Player(level.playerX, level.playerY);
	player.maxJumpAmm = level.maxJumpAmm;
	player.jumpAmm = level.maxJumpAmm;
	add(player);
	player.test();
	// add hud
	deathCounter = new FlxText(0, FlxG.height - 48, FlxG.width, "Deaths: " + level.deaths);
	JamUtils.setupText(deathCounter, 48, 'left', 'Small.otf');
	add(deathCounter);
	deathCounter.cameras = [camHUD];

	timeCounter = new FlxText(FlxG.width - 155, FlxG.height - 48, FlxG.width, "");
	JamUtils.setupText(timeCounter, 48, 'left', 'Small.otf');
	add(timeCounter);
	timeCounter.cameras = [camHUD];

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
	deathCounter.text = "Deaths: " + level.deaths;
	if (active) {
		time += elapsed * 1000;
		timeCounter.text = CoolUtil.timeToStr(time);
	}
	FlxG.overlap(level.eventBoxes, player, nextStage);
	level.update(player, elapsed);
	if (controls.BACK)
		FlxG.switchState(new FreeplayState());
	if (!active) {
		if (controls.ACCEPT) {
			if (typing.isTyping)
				typing.skip();
			else
				typing.continueDialogue();
		}
	}
}

function nextStage() {
	if (level.curStage == level.stages.length - 1) {
		DeathCounter.saveBestTime(level.level, time);
		FlxG.switchState(new MainMenuState());
	}
	player.x = level.playerX;
	player.y = level.playerY;
	level.loadStage(1);
}

function beatHit(curBeat:Int) {}
function stepHit(curStep:Int) {}
function measureHit(curMeasure:Int) {}

function closeDialogue() {
	player.test();
}
