import office.Room;
import platformer.Level;
import platformer.Player;
import FunkinTypeText;
import openfl.geom.Matrix;

public var room:Room;
public var level:Level;
public var player:Player;
var script:Script;
public var typing:FunkinTypeText = new FunkinTypeText(0, 0, FlxG.width, 8);
public var deathCounter:FlxText;
public var timeCounter:FlxText;
public var blend = new FlxSprite();
public var blend2 = new FlxSprite();
public var vignette = new FlxSprite();
public var flash = new FlxSprite();
public var camOffice:FlxCamera = new FlxCamera();
public var camGame:FlxCamera = new FlxCamera();
public var camHUD:FlxCamera = new FlxCamera();
public var gameon:Bool = false;
public var active:Bool = true;
public var isOffice:Bool = true;
public var time:Float = 0;

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
	flash = new FlxSprite().loadGraphic(Paths.image("game/flash"));
	flash.screenCenter();
	flash.setGraphicSize(FlxG.width * 2.5, FlxG.height * 2);
	flash.alpha = 0.75;
	flash.cameras = [camHUD];
	add(flash);

	vignette = new FlxSprite().loadGraphic(Paths.image("game/vignette"));
	vignette.setGraphicSize(FlxG.width, FlxG.height);
	vignette.screenCenter();
	vignette.cameras = [camHUD];
	add(vignette);

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
	CoolUtil.playMusic(Paths.music(level.music), true, 0.8, true, level.bpm);
}

function update(elapsed:Float) {
	var mouse = FlxG.mouse.getScreenPosition(camHUD);
	flash.x = mouse.x - flash.width / 2;
	flash.y = mouse.y - flash.height / 2;
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
		deathCounter.text = "Deaths: " + level.deaths;
		time += elapsed * 1000;
		timeCounter.text = CoolUtil.timeToStr(time);

		level.update(player, elapsed);
		FlxG.overlap(level.eventBoxes, player, nextStage);

		if (FlxG.keys.justPressed.H) {
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
			])
				FlxTween.tween(shader, {fov: gameon ? 3 : 0.5}, 0.75, {ease: gameon ? FlxEase.cubeInOut : FlxEase.quartOut});

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
			FlxTween.tween(flash, {alpha: gameon ? 0 : 0.75}, gameon ? 0.5 : 0.1);
			FlxG.sound.music.volume = gameon ? 0.8 : 0.25;
			if (!gameon) {
				level.background.visible = false;
			}
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
