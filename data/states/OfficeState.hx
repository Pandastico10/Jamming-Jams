import office.Room;
import office.MonsterManager;
import office.Flashlight;
import platformer.Level;
import platformer.Player;
import platformer.DeathCounter;
import FunkinTypeText;
import flixel.util.FlxSpriteUtil;
import haxe.io.Path;

public var room:Room;
public var level:Level;
public var player:Player;
public var manager:Manager;
public var flashlight:Flashlight;
var script:Script;
public var typing:FunkinTypeText = new FunkinTypeText(0, 0, FlxG.width, 8);
public var blend = new FlxSprite();
public var blend2 = new FlxSprite();
public var vignette = new FlxSprite();
public var flash1 = new FlxSprite();
public var flash0 = new FlxSprite();
public var flashbang = new FlxSprite();
public var drone = new FlxSound();
public var flashOnsfx = new FlxSound();
public var flashOffsfx = new FlxSound();
public var leftDoor:Bool = false;
public var rightDoor:Bool = false;
public var leftFlash:Bool = false;
public var rightFlash:Bool = false;
public var moving:Bool = false;
public var gameon:Bool = false;
public var active:Bool = true;
public var isOffice:Bool = true;
public var curStage:Int = 0;
public var camOffice:FlxCamera = new FlxCamera();
public var camGame:FlxCamera = new FlxCamera();
public var camHUD:FlxCamera = new FlxCamera();
var scanline = new CustomShader("scanline");
var glow = new CustomShader("RTX");
var changingStage:Bool = false;

function create() {
	persistentUpdate = false;
	persistentDraw = true;

	FlxG.cameras.add(camOffice, false);
	camOffice.bgColor = 0xFF353535;
	camOffice.zoom = 0.35;

	FlxG.cameras.add(camGame, true);
	camGame.bgColor = 0;
	camGame.alpha = 0;

	FlxG.cameras.add(camHUD, false);
	camHUD.bgColor = 0;

	if (FlxG.save.data.shaders) {
		camGame.addShader(glow);
		camGame.addShader(scanline);
	}

	room = new Room(camOffice);
	add(room.sprites);

	level = new Level(data, camGame);
	curStage = level.curStage;

	add(level.backgroundSprites);
	add(level.particles);
	add(level.cannons);
	add(level.emitter);
	add(level.boxes);
	add(level.eventBoxes);

	flashbang.makeGraphic(FlxG.width, FlxG.height, 0x7EFFFFFF);
	add(flashbang);
	flashbang.alpha = 0;
	flashbang.scrollFactor.set(0, 0);
	flashbang.cameras = [camGame];

	level.background.visible = false;

	player = new Player(level.playerX, level.playerY, level.maxJumpAmm);
	player.cameras = [camGame];
	add(player);
	player.test();

	manager = new Manager(level.leftAi, level.rightAi, level.backAi, level.upAi);

	if (level.levelWidth > 768) {
		camGame.setScrollBoundsRect(0, 0, level.levelWidth, camGame.height, true);
		camGame.follow(player);
		camGame.followLerp = 0.05;
	}

	blend2.makeGraphic(3500, 2500, 0xFF000000);
	blend2.alpha = 0;
	blend2.cameras = [camOffice];
	blend2.screenCenter();
	add(blend2);

	flashlight = new Flashlight(level.leftAi, level.rightAi, level.backAi, level.upAi);

	add(flashlight.flashSprites);
	flashlight.flashSprites.cameras = [camOffice];

	vignette = new FlxSprite().loadGraphic(Paths.image("game/vignette"));
	vignette.setGraphicSize(FlxG.width, FlxG.height);
	vignette.screenCenter();
	vignette.cameras = [camHUD];
	add(vignette);

	add(flashlight.sprites);
	flashlight.sprites.cameras = [camHUD];
	flashlight.update(1, false, 0, 0);

	level.hudElements.cameras = [camHUD];
	add(level.hudElements);

	for (path in Paths.getFolderContent("data/scripts/")) {
		if (Path.extension(path) == "hx" && Path.withoutExtension(path) == level.level) {
			script = importScript("data/scripts/" + level.level);
			break;
		}
	}

	CoolUtil.playMusic(Paths.music(level.music), true, 0.8, true, level.bpm);

	FlxG.sound.music.pause();

	drone = FlxG.sound.load(Paths.music("drone"), 1, true);
	flashOnsfx = FlxG.sound.load(Paths.sound("sfxFlashlightOn"), 1);
	flashOffsfx = FlxG.sound.load(Paths.sound("sfxFlashlightOff"), 1);
}

function update(elapsed:Float) {
	var mouse = FlxG.mouse.getScreenPosition(camOffice);

	if (FlxG.state.subState != null) {
		persistentUpdate = true;
		persistentDraw = true;
	} else {
		persistentUpdate = false;
		persistentDraw = true;
	}

	if (controls.BACK) {
		if (!active) {
			FlxG.switchState(new MainMenuState());
			return;
		} else {
			openSubState(new ModSubState("pauseSubstate", {
				hasAI: isOffice,
				level: level.level,
				gameon: gameon,
				drone: drone
			}));
			return;
		}
	}

	room.update(elapsed);
	if (active) {
		level.update(player, elapsed);
		curStage = level.curStage;
		if (mouse.x > -548 && mouse.x < -59 && mouse.y > -64 && mouse.y < 846) {
			leftDoor = FlxG.mouse.pressedRight;
			leftFlash = FlxG.mouse.pressed && !flashlight.isRecharging;
		}
		if (mouse.x > 1097 && mouse.x < 1514 && mouse.y > 52 && mouse.y < 1006) {
			rightDoor = FlxG.mouse.pressedRight;
			rightFlash = FlxG.mouse.pressed && !flashlight.isRecharging;
		}
		var flashOn = FlxG.mouse.pressed && !gameon;
		flashlight.update(elapsed, flashOn, mouse.x, mouse.y);
		manager.updateDefenses(leftDoor, rightDoor, room.lookingBehind, flashlight.isOn, leftFlash, rightFlash);
		manager.update(elapsed, room.lookingBehind);
		if (manager.gotcha)
			trace("you died!");
		FlxG.overlap(level.eventBoxes, player, nextStage);
		if (FlxG.mouse.justPressed && !gameon && !flashlight.isRecharging)
			flashOnsfx.play();
		if (FlxG.mouse.justReleased && !gameon && !flashlight.isRecharging)
			flashOffsfx.play();
		if (controls.getJustPressed("cabin_game") && !room.lookingBehind && !moving)
			gameOn();
	} else {
		if (controls.ACCEPT) {
			if (typing.isTyping)
				typing.skip();
			else
				typing.continueDialogue();
		}
	}
}

function gameOn() {
	moving = true;
	gameon = !gameon;

	room.gameon = gameon;
	player.playable = gameon;

	for (shader in [
		room.shaderLeft,
		room.shaderMid,
		room.shaderBack,
		room.shaderRight,
		room.shaderTop,
		room.shaderBottom
	]) {
		FlxTween.tween(shader, {fov: gameon ? 3 : 0.5}, 0.75, {
			ease: gameon ? FlxEase.cubeInOut : FlxEase.quartOut
		});
	}

	FlxTween.tween({value: 0}, {value: 1}, 0.75, {
		onComplete: function(_) {
			moving = false;
		}
	});

	FlxTween.cancelTweensOf(camGame);
	FlxTween.cancelTweensOf(level.backgroundOverlay);

	FlxTween.tween(camGame, {alpha: gameon ? 1 : 0}, gameon ? 0.5 : 0.1, {
		onComplete: function(_) {
			if (gameon) {
				level.background.visible = true;
				level.backgroundOverlay.visible = true;
				level.backgroundOverlay.alpha = 1;

				FlxTween.tween(level.backgroundOverlay, {alpha: 0.975}, 0.5);
			} else {
				level.backgroundOverlay.visible = false;
				level.backgroundOverlay.alpha = 1;
			}
		}
	});

	FlxTween.tween(blend2, {alpha: gameon ? 1 : 0}, gameon ? 0.5 : 0.1);
	FlxTween.tween(vignette, {alpha: gameon ? 0 : 1}, gameon ? 0.5 : 0.1);
	FlxTween.tween(flashlight.flash0, {alpha: gameon ? 0 : 0.75}, gameon ? 0.5 : 0.1);
	FlxTween.tween(flashlight.flash1, {alpha: gameon ? 0 : 0.75}, gameon ? 0.5 : 0.1);

	FlxTween.cancelTweensOf(drone);

	if (!gameon) {
		FlxG.sound.music.pause();

		drone.resume();
		drone.volume = 0;

		FlxTween.tween(drone, {volume: 0.8}, 0.5);

		level.background.visible = false;
	} else {
		FlxG.sound.music.resume();

		FlxTween.tween(drone, {volume: 0}, 0.5, {
			onComplete: function(_) {
				if (gameon)
					drone.pause();
			}
		});
	}
}

function nextStage() {
	if (changingStage)
		return;

	changingStage = true;

	if (level.curStage == level.stages.length - 1) {
		DeathCounter.saveBestTime(level.level, level.time * 1000);
		DeathCounter.saveBestDeaths(level.level, level.deaths);
		FlxG.switchState(new MainMenuState());
		return;
	}
	flashbang.alpha = 1;
	FlxSpriteUtil.fadeOut(flashbang, 1);

	if (script != null)
		script.call("nextStage");

	FlxG.sound.play(Paths.sound("win"));

	level.loadStage(1);

	curStage = level.curStage;

	player.x = level.playerX;
	player.y = level.playerY;

	new FlxTimer().start(0.05, function(_) {
		changingStage = false;
	});
}

function beatHit(curBeat:Int) {}
function stepHit(curStep:Int) {}
function measureHit(curMeasure:Int) {}

function closeDialogue() {
	player.test();
}
