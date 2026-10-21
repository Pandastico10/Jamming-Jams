import office.Room;
import office.MonsterManager;
import platformer.Level;
import platformer.Player;
import FunkinTypeText;

public var room:Room;
public var level:Level;
public var player:Player;
public var manager:Manager;
var script:Script;
public var typing:FunkinTypeText = new FunkinTypeText(0, 0, FlxG.width, 8);
public var blend = new FlxSprite();
public var blend2 = new FlxSprite();
public var vignette = new FlxSprite();
public var flash1 = new FlxSprite();
public var flash0 = new FlxSprite();
public var drone = new FlxSound();
public var flashOn:Bool;
public var camOffice:FlxCamera = new FlxCamera();
public var camGame:FlxCamera = new FlxCamera();
public var camHUD:FlxCamera = new FlxCamera();
public var gameon:Bool = false;
public var active:Bool = true;
public var isOffice:Bool = true;

function create() {
	FlxG.cameras.add(camOffice, false);
	camOffice.bgColor = 0xFF353535;
	camOffice.zoom = 0.35;

	FlxG.cameras.add(camGame, true);
	camGame.bgColor = 0;
	camGame.alpha = 0;

	FlxG.cameras.add(camHUD, false);
	camHUD.bgColor = 0;

	room = new Room(camOffice);
	add(room.sprites);

	level = new Level(data, camGame);

	add(level.backgroundSprites);
	add(level.cannons);
	add(level.boxes);
	add(level.eventBoxes);

	level.background.visible = false;

	player = new Player(level.playerX, level.playerY);
	player.maxJumpAmm = level.maxJumpAmm;
	player.jumpAmm = level.maxJumpAmm;
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

	// add hud
	flash1 = new FlxSprite().loadGraphic(Paths.image("game/flash1"));
	flash1.screenCenter();
	flash1.setGraphicSize(FlxG.width * 2.5, FlxG.height * 2);
	flash1.alpha = 0.8;
	flash1.cameras = [camHUD];
	add(flash1);

	flash0 = new FlxSprite().loadGraphic(Paths.image("game/flash0"));
	flash0.screenCenter();
	flash0.setGraphicSize(FlxG.width * 2.5, FlxG.height * 2);
	flash0.alpha = 0.8;
	flash0.cameras = [camHUD];
	add(flash0);

	vignette = new FlxSprite().loadGraphic(Paths.image("game/vignette"));
	vignette.setGraphicSize(FlxG.width, FlxG.height);
	vignette.screenCenter();
	vignette.cameras = [camHUD];
	add(vignette);

	level.hudElements.cameras = [camHUD];
	add(level.hudElements);

	for (path in Paths.getFolderContent("data/scripts/")) {
		if (Path.extension(path) == "hx" && Path.withoutExtension(path) == level.level) {
			script = importScript("data/scripts/" + level.level);
			break;
		}
	}
	CoolUtil.playMusic(Paths.music(level.music), true, 0.8, true, level.bpm);
	drone.loadEmbedded(Paths.music("drone"), true);
	drone.group = FlxG.sound.defaultMusicGroup;
	FlxG.sound.defaultMusicGroup.add(drone);
	drone.volume = 0;
	drone.play();
}

function update(elapsed:Float) {
	var mouse = FlxG.mouse.getScreenPosition(camHUD);
	flashOn = FlxG.mouse.pressed;

	flash1.x = mouse.x - flash1.width / 2;
	flash1.y = mouse.y - flash1.height / 2;
	if (controls.BACK)
		FlxG.switchState(new MainMenuState());
	room.update(elapsed);
	if (!active) {
		if (controls.ACCEPT) {
			if (typing.isTyping)
				typing.skip();
			else
				typing.continueDialogue();
		}
	}

	if (active) {
		level.update(player, elapsed);
		manager.update(elapsed);
		FlxG.overlap(level.eventBoxes, player, nextStage);

		flash1.visible = flashOn;
		flash0.visible = !flashOn;
		if (FlxG.mouse.justPressed && !gameon)
			FlxG.sound.play(Paths.sound('sfxFlashlightOn'));
		if (FlxG.mouse.justReleased && !gameon)
			FlxG.sound.play(Paths.sound('sfxFlashlightOff'));

		if (FlxG.keys.justPressed.W && !room.lookingBehind) {
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
			FlxTween.tween(flash0, {alpha: gameon ? 0 : 0.75}, gameon ? 0.5 : 0.1);
			FlxTween.tween(flash1, {alpha: gameon ? 0 : 0.75}, gameon ? 0.5 : 0.1);

			// FlxG.sound.music.volume = gameon ? 0.8 : 0.25;

			if (!gameon) {
				FlxG.sound.music.pause();
				drone.fadeIn(2, 0, 2);
			} else {
				FlxG.sound.music.resume();
				drone.pause();
			}

			if (!gameon)
				level.background.visible = false;
		}
	}
}

function nextStage() {
	FlxG.sound.play(Paths.sound('win'));
	if (level.curStage == level.stages.length - 1) {
		DeathCounter.saveBestTime(level.level, level.time * 1000);
		FlxG.switchState(new MainMenuState());
		return;
	}
	player.x = level.playerX;
	player.y = level.playerY;
	level.loadStage(1);
}
