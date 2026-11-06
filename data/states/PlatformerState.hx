import platformer.Level;
import platformer.Player;
import FunkinTypeText;
import flixel.util.FlxSpriteUtil;

public var level:Level;
public var player:Player;
var script:Script;
public var blend = new FlxSprite();
public var flashbang = new FlxSprite();
public var camGame:FlxCamera = new FlxCamera();
public var camBg:FlxCamera = new FlxCamera();
public var camHUD:FlxCamera = new FlxCamera();
public var typing:FunkinTypeText = new FunkinTypeText(0, 0, FlxG.width, 8);
public var curStage:Int = 0;
public var isOffice:Bool = false;
public var active:Bool = true;
public var noclip:Bool = false;
public var comingBack:Bool = false;

// game shaders
var scanline = new CustomShader('scanline');
var glow = new CustomShader('RTX');

typing.onStart.add(() -> {
	// do this when dialogue starts
	if (isOffice)
		room.gameon = true;
	blend.makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
	blend.alpha = 0;
	blend.cameras = [camHUD];
	insert(0, blend);
	FlxTween.tween(blend, {alpha: 0.75}, 2, {ease: FlxEase.cubeOut});
});
typing.onComplete.add(() -> {
	// do this when dialogue finishes typing
	if (isOffice) {
		room.gameon = false;
		drone.play();
	}
	active = true;
	player.test();
	FlxTween.tween(blend, {alpha: 0}, 1, {ease: FlxEase.cubeOut});
	FlxTween.tween(typing, {alpha: 0}, 1, {ease: FlxEase.cubeOut});
	FlxG.sound.music.resume();
});
typing.onProgress.add(() -> {
	typing.screenCenter(); // re-centers the text to the screen on every new character typed.
});
function create() {
	comingBack = data.comingBack;
	FlxG.cameras.add(camBg, false);
	blend.makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
	add(blend);
	blend.cameras = [camBg];
	FlxG.cameras.add(camGame, true);
	camGame.bgColor = 0;
	FlxG.cameras.add(camHUD, false);
	camHUD.bgColor = 0;

	if (FlxG.save.data.shaders) {
		camGame.addShader(glow);
		camGame.addShader(scanline);
	}
	// load the level  name // assign cam
	level = new Level(data.level, camGame, data.stage);
	add(level.backgroundSprites);
	add(level.particles);
	add(level.cannons);

	add(level.emitter);
	add(level.boxes);
	add(level.eventBoxes);
	add(level.hudElements);

	curStage = data.stage;
	level.recieveData(data.deaths, data.time);

	flashbang.makeGraphic(FlxG.width, FlxG.height, 0x7EFFFFFF);
	add(flashbang);
	flashbang.alpha = 0;
	flashbang.cameras = [camGame];

	level.hudElements.cameras = [camHUD];
	// add player
	player = new Player(level.playerX, level.playerY, level.maxJumpAmm);
	if (!FlxG.save.data.performance)
		add(player.trail);
	add(player.abilityIndicator);
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
	// trace(level.curStage);
}

function postCreate() {
	if (script != null)
		script.call("nextStage");
	player.applyAbility();
	if (data.isStoryMode && Assets.exists(Paths.json("json/" + data.level))) {
		// trace("dialogue start");
		active = false;
		FlxG.sound.music.pause();

		// stop everything if dialogue exists aka this script
		player.test();
		// start dialogue + setup
		JamUtils.startDialogue(typing, "json/" + data.level);
		add(typing);
		JamUtils.setupText(typing, 48, 'center', 'Outline.ttf');
		typing.cameras = [camHUD];
		typing.sounds = [FlxG.sound.load(Paths.sound("talkSounds/talk"))];
	}
}

function update(elapsed:Float) {
	if (FlxG.state.subState != null) {
		persistentUpdate = true;
		persistentDraw = true;
	} else {
		persistentUpdate = false;
		persistentDraw = true;
	}
	FlxG.overlap(level.eventBoxes, player, nextStage);
	if (!noclip && active) {
		// godmode on ?
		level.godmode = FlxG.save.data.canDie;

		if (player.slowdown) {
			camGame.zoom = CoolUtil.fpsLerp(camGame.zoom, 1.075, 0.1);
		} else {
			camGame.zoom = CoolUtil.fpsLerp(camGame.zoom, 1, 0.1);
		}

		level.update(player, elapsed);
		curStage = level.curStage;
	}
	if (controls.BACK) {
		if (!active) {
			FlxG.switchState(new MainMenuState());
		} else {
			openSubState(new ModSubState('pauseSubstate', {
				hasAI: isOffice,
				level: level.level,
				isStoryMode: data.isStoryMode,
				stage: data.stage,
				deaths: level.deaths,
				time: level.time,
				stage: curStage
			}));
		}
	}
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
	noclip = true;
	if (level.curStage == level.stages.length - 1) {
		if (script != null)
			script.call("levelComplete");
		DeathCounter.saveBestTime(level.level, level.time * 1000);
		DeathCounter.saveBestDeaths(level.level, level.deaths);
		// make open win substate later
		openSubState(new ModSubState('winSubstate', {
			hasAI: isOffice,
			level: level.level,
			isStoryMode: data.isStoryMode,
			deaths: level.deaths,
			time: level.time
		}));
		return;
	}

	level.loadStage(1);
	flashbang.alpha = 1;
	FlxSpriteUtil.fadeOut(flashbang, 1);
	if (script != null)
		script.call("nextStage");

	FlxG.sound.play(Paths.sound("win"));
	player.x = level.playerX;
	player.y = level.playerY;
	// to avoid getting stuck on walls when going back to spawn
	new FlxTimer().start(0.05, function(_) {
		noclip = false;
	});
}

function beatHit(curBeat:Int) {}
function stepHit(curStep:Int) {}
function measureHit(curMeasure:Int) {}

function closeDialogue() {
	player.test();
}
