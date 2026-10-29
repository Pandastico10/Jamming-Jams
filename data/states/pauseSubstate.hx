import funkin.options.OptionsMenu;
import openfl.display.BlendMode;
import flixel.addons.display.FlxBackdrop;
import platformer.DeathCounter;
import Xml;
import FunkinSignal;

var levelName:FlxText;
var levelInfo:FlxText;
var Highscore:FlxText;
var menuItems:Array<String>;
var curSelected:Int = 0;

// trans bool yayyyyy
var trans:Bool = false;
var pauseMusic:FlxSound;
var options:Array<String> = ["Resume", "Restart", "Options", "Exit"];
var texts:Array<FlxText> = [];
var curSelected:Int = 0;
var bg = new FlxSprite();
var blend = new FlxSprite();
var pauseTarget:FlxSound;
var pauseTargetVolume:Float = 0.8;
var pauseTargetWasPlaying:Bool = false;

function create() {
	camera = new FlxCamera();
	camera.bgColor = 0;
	FlxG.cameras.add(camera, false);
	if (!data.hasAI || data.gameon) {
		pauseTarget = FlxG.sound.music;
	} else {
		pauseTarget = data.drone;
	}

	if (pauseTarget != null) {
		pauseTargetVolume = pauseTarget.volume;
		pauseTargetWasPlaying = pauseTarget.playing;

		FlxTween.cancelTweensOf(pauseTarget);

		if (pauseTargetWasPlaying) {
			FlxTween.tween(pauseTarget, {volume: 0}, 0.5, {
				onComplete: function(_) {
					pauseTarget.pause();
				}
			});
		}
	}
	blend.makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
	add(blend);
	blend.cameras = [camera];
	bg.alpha = 0;
	FlxTween.tween(blend, {alpha: 0.8}, 1, {ease: FlxEase.cubeOut});

	bg = new FlxBackdrop(Paths.image('game/square'), FlxAxes.XY, 0, 0);
	bg.setGraphicSize(FlxG.width, FlxG.height);
	bg.velocity.set(-30, 7.5);
	bg.alpha = 0;
	bg.blend = BlendMode.MULTIPLY;
	add(bg);
	bg.cameras = [camera];
	FlxTween.tween(bg, {alpha: 0.5}, 1, {ease: FlxEase.cubeOut});
	bg.screenCenter();
	for (i in 0...options.length) {
		var txt = new FlxText(0, 0, FlxG.width, options[i]);
		txt.screenCenter();
		txt.y += i * 62.5;
		add(txt);
		txt.alpha = 0;
		FlxTween.tween(txt, {alpha: 1}, 1, {ease: FlxEase.cubeOut});
		JamUtils.setupText(txt, 32, 'center', "Small.otf");
		texts.push(txt);
		txt.cameras = [camera];
	}

	var xml = Xml.parse(Assets.getText(Paths.xml("levels/" + data.level))).firstElement();
	var level = xml.get("name");
	var artist = xml.get("artist");
	var bpm = Std.parseInt(xml.get("bpm"));
	var deaths = DeathCounter.loadBestDeaths(data.level);
	var time = DeathCounter.loadBestTime(data.level);

	levelName = new FlxText(0, 0, FlxG.width, level);
	JamUtils.setupText(levelName, 60, 'center', "outline.ttf");
	levelName.screenCenter();
	levelName.y -= 62.5 * 2;
	levelName.cameras = [camera];
    levelName.alpha = 0;
    FlxTween.tween(levelName, {alpha: 1}, 1, {ease: FlxEase.cubeOut});
    texts.push(levelName);
	add(levelName);

	levelInfo = new FlxText(0, 0, FlxG.width, 'by: ' + artist + ' (' + bpm + ' bpm)');
	JamUtils.setupText(levelInfo, 32, 'center', "outline.ttf");
	levelInfo.screenCenter();
	levelInfo.y -= 62.5;
	levelInfo.cameras = [camera];
    levelInfo.alpha = 0;
    FlxTween.tween(levelInfo, {alpha: 1}, 1, {ease: FlxEase.cubeOut});
    texts.push(levelInfo);
	add(levelInfo);

	changeSelect(0);
}

function update(elapsed:Float) {
	if ((FlxG.keys.justPressed.DOWN || FlxG.keys.justPressed.RIGHT) && !trans)
		changeSelect(1);
	if ((FlxG.keys.justPressed.UP || FlxG.keys.justPressed.LEFT) && !trans)
		changeSelect(-1);
	if (controls.ACCEPT && !trans) {
		switch (options[curSelected]) {
			case "Resume":
				trans = true;

				if (pauseTarget != null && pauseTargetWasPlaying) {
					FlxTween.cancelTweensOf(pauseTarget);
					pauseTarget.resume();
					pauseTarget.volume = 0;
					FlxTween.tween(pauseTarget, {volume: pauseTargetVolume}, 0.5);
				}
				FlxTween.tween(bg, {alpha: 0}, 0.5);
				for (i in texts)
					FlxTween.tween(i, {alpha: 0}, 0.5);
				FlxTween.tween(blend, {alpha: 0}, 0.5);
				new FlxTimer().start(0.5, function(_) {
					close();
				});
			// close();
			case "Restart":
				trans = true;
				FlxG.resetState();
			case "Options":
				trans = true;
				if (data.hasAI) {
					FlxG.switchState(new OptionsMenu((_) -> FlxG.switchState(new ModState("OfficeState", data.level))));
				} else {
					FlxG.switchState(new OptionsMenu((_) -> FlxG.switchState(new ModState("PlatformerState", data.level))));
				}
			case "Exit":
				trans = true;
				FlxG.switchState(new MainMenuState());
		}
	}
}

function changeSelect(cur:Int) {
	curSelected = FlxMath.wrap(curSelected + cur, 0, texts.length - 3);
	CoolUtil.playMenuSFX(0, 1);
	for (i in 0...texts.length-2) {
		texts[i].color = i == curSelected ? FlxColor.YELLOW : FlxColor.WHITE;
	}
}
