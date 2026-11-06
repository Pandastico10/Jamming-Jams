import openfl.display.BlendMode;
import flixel.addons.display.FlxBackdrop;
import platformer.DeathCounter;
import flixel.util.FlxSpriteUtil;
import FunkinTypeText;
import haxe.io.Path;
import Xml;

var levelName:FlxText;
var levelComplete:FlxText;
var levelInfo:FlxText;
var deathCounter:FlxText;
var timeCounter:FlxText;
public var typing:FunkinTypeText = new FunkinTypeText(0, 0, FlxG.width, 8);
//whar
var Highscore:FlxText;

// trans bool yayyyyy
var trans:Bool = false;
var ended = false;
public var active:Bool = true;
public var dialogueExists:Bool = false;
var options:Array<String> = ["Next Level", "Restart Level", "Exit"];
var texts:Array<FlxText> = [];
var curSelected:Int = 0;
var bg = new FlxSprite();
var blend = new FlxSprite();
public var flashbang = new FlxSprite();
var pauseTarget:FlxSound;
var winMusic:FlxSound;
var next:String;

typing.onComplete.add(() -> {
	endDialogue();
});
typing.onProgress.add(() -> {
	typing.screenCenter(); // re-centers the text to the screen on every new character typed.
});
function create() {
	FlxG.sound.play(Paths.sound("win"));
	camera = new FlxCamera();
	camera.bgColor = 0;
	FlxG.cameras.add(camera, true);

	if (!data.hasAI || data.gameon)
		pauseTarget = FlxG.sound.music;
	else
		pauseTarget = data.drone;

	if (pauseTarget != null) {
		FlxTween.cancelTweensOf(pauseTarget);

		if (pauseTarget.playing) {
			FlxTween.tween(pauseTarget, {volume: 0}, 0.5, {
				onComplete: function(_) {
					pauseTarget.pause();
				}
			});
		}
	}
	if (!data.isStoryMode)
		options.shift();

	setupTexts();

	flashbang.alpha = 1;
	FlxSpriteUtil.fadeOut(flashbang, 2.5);
	winMusic = FlxG.sound.load(Assets.getMusic(Paths.music("Sakura-core")), 0, true);
	winMusic.persist = false;
	winMusic.group = FlxG.sound.defaultMusicGroup;
	winMusic.play(false, FlxG.random.int(0, Std.int(winMusic.length / 2)));

	if (data.isStoryMode) {
		for (path in Paths.getFolderContent("data/json/")) {
			if (Path.extension(path) == "json" && Path.withoutExtension(path) == data.level + "-end") {
				dialogueExists = true;
				startDialogue(Path.withoutExtension(path));
				break;
			}
		}
	} else {
		endDialogue();
	}

	changeSelect(0);
}

function update(elapsed:Float) {
	if (ended)
	{
		if (winMusic != null && winMusic.volume < 0.75)
		winMusic.volume += 0.03 * elapsed;
	}
	if (!active) {
		if (controls.ACCEPT) {
			if (typing.isTyping)
				typing.skip();
			else
				typing.continueDialogue();
		}
		return;
	}
	if ((FlxG.keys.justPressed.DOWN || FlxG.keys.justPressed.RIGHT) && !trans)
		changeSelect(1);
	if ((FlxG.keys.justPressed.UP || FlxG.keys.justPressed.LEFT) && !trans)
		changeSelect(-1);
	if (controls.ACCEPT && !trans) {
		switch (options[curSelected]) {
			case "Next Level":
				trans = true;
				transitionOut();
				new FlxTimer().start(2, function(_) {
					nextLvl(data.level);
				});

			case "Restart Level":
				trans = true;
				transitionOut();
				new FlxTimer().start(2, function(_) {
					FlxG.resetState();
				});

			case "Exit":
				trans = true;
				transitionOut();
				new FlxTimer().start(2, function(_) {
					if (data.isStoryMode) {
						FlxG.switchState(new MainMenuState());
					} else {
						FlxG.switchState(new ModState("JamFreeplay"));
					}
				});
		}
	}
}

function transitionOut() {
	CoolUtil.playMenuSFX(1, 1);
	flashbang.alpha = 1;
	FlxSpriteUtil.fadeOut(flashbang, 2.5);
	for (i in 0...texts.length) {
		FlxTween.tween(texts[i], {alpha: 0}, 2);
	}
	FlxSpriteUtil.fadeOut(bg, 2);
}

function nextLvl(currentLvl:String) {
	var xml = Xml.parse(Assets.getText(Paths.xml("levels/" + currentLvl))).firstElement();
	if (xml.exists("nextLvl")) {
		next = xml.get("nextLvl");
	} else {
		FlxG.switchState(new MainMenuState());
		return;
	}
	if (next == 'credits') {
		FlxG.switchState(new ModState("DialogueState", true));
		return;
	}
	var nextXml = Xml.parse(Assets.getText(Paths.xml("levels/" + next))).firstElement();

	var leftAi = Std.parseInt(nextXml.get("leftAi") ?? "0");
	var rightAi = Std.parseInt(nextXml.get("rightAi") ?? "0");
	var backAi = Std.parseInt(nextXml.get("backAi") ?? "0");
	var upAi = Std.parseInt(nextXml.get("upAi") ?? "0");

	var hasAI = leftAi > 0 || rightAi > 0 || backAi > 0 || upAi > 0;

	if (hasAI) {
		FlxG.switchState(new ModState("OfficeState", {
					level: next,
					isStoryMode: true,
					stage: 0
				}));
	} else {
		FlxG.switchState(new ModState("PlatformerState", {
					level: next,
					isStoryMode: true,
					stage: 0
				}));
	}
}

function changeSelect(change:Int) {
	curSelected = FlxMath.wrap(curSelected + change, 0, options.length - 1);
	CoolUtil.playMenuSFX(0, 1);
	for (i in 0...options.length)
		texts[i].color = i == curSelected ? FlxColor.YELLOW : FlxColor.WHITE;
}

function startDialogue(json:String) {
	trace("starting dialogue at: " + json);

	active = false;
	JamUtils.startDialogue(typing, "json/" + json);
	JamUtils.setupText(typing, 48, 'center', 'Outline.ttf');

	typing.cameras = [camera];
	typing.alpha = 0;
	typing.sounds = [FlxG.sound.load(Paths.sound("talkSounds/talk"))];
	add(typing);
	FlxTween.tween(typing, {alpha: 1}, 2, {
		ease: FlxEase.cubeOut
	});
}

function endDialogue() {
	ended = true;
	FlxTween.tween(typing, {alpha: 0}, 0.5, {
		ease: FlxEase.cubeOut
	});

	new FlxTimer().start(2, function(_) {
		active = true;
	});
	for (i in 0...texts.length) {
		var targetY = texts[i].y;
		texts[i].y = FlxG.height + 50;
		texts[i].alpha = 0;
		FlxTween.tween(texts[i], {y: targetY, alpha: 1}, 1, {
			ease: FlxEase.cubeOut,
			startDelay: i * 0.10
		});
	}
}

function setupTexts() {
	blend.makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
	add(blend);
	blend.cameras = [camera];

	bg = new FlxBackdrop(Paths.image('game/square'), FlxAxes.XY, 0, 0);
	bg.setGraphicSize(FlxG.width, FlxG.height);
	bg.velocity.set(-30, 7.5);
	bg.alpha = 0.35;
	// bg.blend = BlendMode.MULTIPLY;
	add(bg);
	bg.cameras = [camera];
	bg.screenCenter();
	for (i in 0...options.length) {
		var txt = new FlxText(0, 0, FlxG.width, options[i]);
		txt.screenCenter();
		txt.y += i * 62.5;
		add(txt);
		txt.alpha = 0;
		JamUtils.setupText(txt, 32, 'center', "Small.otf");
		texts.push(txt);
		txt.cameras = [camera];
	}

	var xml = Xml.parse(Assets.getText(Paths.xml("levels/" + data.level))).firstElement();
	var level = xml.get("name");
	var artist = xml.get("artist");
	var bpm = Std.parseInt(xml.get("bpm"));

	levelName = new FlxText(0, 0, FlxG.width, level);
	JamUtils.setupText(levelName, 60, 'center', "outline.ttf");
	levelName.screenCenter();
	levelName.y -= 62.5 * 2;
	levelName.cameras = [camera];
	levelName.alpha = 0;
	texts.push(levelName);
	add(levelName);
	levelComplete = new FlxText(0, 0, FlxG.width, "Level Complete!");
	JamUtils.setupText(levelComplete, 116, 'center', "outline.ttf");
	levelComplete.screenCenter();
	levelComplete.y -= 62.5 * 4;
	levelComplete.cameras = [camera];
	levelComplete.alpha = 0;
	levelComplete.color = FlxColor.YELLOW;

	texts.push(levelComplete);
	add(levelComplete);
	levelInfo = new FlxText(0, 0, FlxG.width, 'by: ' + artist + ' (' + bpm + ' bpm)');
	JamUtils.setupText(levelInfo, 32, 'center', "outline.ttf");
	levelInfo.screenCenter();
	levelInfo.y -= 62.5;
	levelInfo.cameras = [camera];
	levelInfo.alpha = 0;
	texts.push(levelInfo);
	add(levelInfo);

	deathCounter = new FlxText(0, FlxG.height - 48, FlxG.width, "Deaths: " + data.deaths);
	JamUtils.setupText(deathCounter, 48, 'left', "Small.otf");
	deathCounter.alpha = 0;
	deathCounter.color = FlxColor.YELLOW;
	add(deathCounter);
	texts.push(deathCounter);
	timeCounter = new FlxText(FlxG.width - 240, FlxG.height - 48, FlxG.width, "Time: " + CoolUtil.timeToStr(data.time * 1000));
	JamUtils.setupText(timeCounter, 48, 'left', 'Small.otf');
	timeCounter.alpha = 0;
	timeCounter.color = FlxColor.YELLOW;
	add(timeCounter);
	texts.push(timeCounter);

	flashbang.makeGraphic(FlxG.width, FlxG.height, 0x7EFFFFFF);
	add(flashbang);
	flashbang.alpha = 0;
	flashbang.cameras = [camera];
}
