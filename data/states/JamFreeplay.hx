import openfl.display.BlendMode;
import flixel.addons.display.FlxBackdrop;
import flixel.text.FlxText.FlxTextBorderStyle;
import funkin.editors.EditorPicker;
import funkin.editors.EditorTreeMenu;
import flixel.ui.FlxBar;
import flixel.ui.FlxBar.FlxBarFillDirection;
import funkin.editors.ui.UISliceSprite;
import platformer.DeathCounter;
import haxe.io.Path;
import FunkinTypeText;
import Xml;

var texts:Array<FlxText> = [];
var boxes:Array<UISliceSprite> = [];
var boxesUI:Array<UISliceSprite> = [];
var deathCounter:FlxText;
var timeCounter:FlxText;
var resetText:FlxText;
var levelNameText:FlxText;
var artistText:FlxText;
var icon:FlxSprite;
var bar:FlxBar;
var resetTimer:Float = 0;
var curSelected:Int = 0;
var levels:Array<String> = [];
var textX:Int = 208;
var textY:Float = FlxG.height / 2;
var textSep:Float = 60;
var active:Bool = false;
var lerpTime:Int = 0;
var intendedTime:Int = 0;
var lerpDeath:Int = 0;
var intendedDeath:Int = 0;
var time:Float = 0;
var bg:FlxBackdrop;
var vignette:FlxSprite;
var camBg:FlxCamera = new FlxCamera();
var camMain:FlxCamera;
var backgroundShader = new CustomShader(FlxG.save.data.bgs);
var blur = new CustomShader('blur');
var panelX:Float;
var panelY:Float = 12;
var panelWidth:Float;
var panelHeight:Float;
var isLevelPlatformer:Bool = true;
var modeText:FlxText;
var modeHintText:FlxText;
var curStage:Int = 0;
var maxStage:Int = 12;
var doll:FlxSprite;
var baseScaleY:Float = 0;
var baseScaleX:Float = 0;
var everyTwo:Bool = false;
var typing:FunkinTypeText = new FunkinTypeText(0, 0, 128, 8);

var randomChat:Map<String, String> = [
	"Quarter Circle" => "A song from the 'FNF Never Evers' collection by Sandbag40, featuring famous M.U.G.E.N characters: Homer Simpson & Dee Bee Kaw",
	"Lady's Locker Room" => "A song from the Fanfad 'All eyes on me' featuring Ray Parker Jr & Cherry Pepsi",
	"Dj's Mix" => "An electro swing mashup featuring songs like OR3O - Help Me & AFC - FUEGO EN LA DISCO",
	"Perreo Heart" => "A mashup from popular fanfad 'Third world tournament' for the character: Killer bean that featured on the badmouthfest set",
	"Last man Standing" => "Originally a chase theme for a potential asym game featuring some of my characters, that's why its named that.",
	"level0" => "Its just a test level really, i dont know how you got access to it",
	"Pandamonium" => "The max mode of this game, can you beat the last 2 levels of each story mode level with the difficulty at max?",
	"Bird Brain" => "Remix of a song i liked :]",
	"First Round Loser" => "A Homage to a long running inside joke of mine"
];

var chatBox:UISliceSprite;
var boop:FlxSound;

typing.onProgress.add(() -> {
	if (everyTwo) {
		doll.scale.y = baseScaleY + 0.10;
		doll.scale.x = baseScaleX - 0.10;
		everyTwo = !everyTwo;
	} else {
		everyTwo = !everyTwo;
	}
	chatBox.resize(typing.width + 32, typing.height + 24);
});
function create() {
	CoolUtil.playMenuSong();
	boop = FlxG.sound.load(Paths.sound("boop"), 2, false);

	levels.push("Quarter Circle");
	levels.push(FlxG.save.data.beatlevel1 ? "Lady's Locker Room" : "???");
	levels.push(FlxG.save.data.beatlevel2 ? "Dj's Mix" : "???");
	levels.push(FlxG.save.data.beatlevel3 ? "Perreo Heart" : "???");
	levels.push(FlxG.save.data.beatlevel4 ? "Last man Standing" : "???");
	var newLevels = JamUtils.getList(true);
	for (i in newLevels)
		levels.push(i);

	// levels = CoolUtil.sortAlphabetically(levels);
	setupCameras();
	setupBackground();
	setupMenu();

	for (i in 0...levels.length) {
		var txt = new FlxText(textX, textY + i * textSep, FlxG.width, levels[i]);
		JamUtils.setupText(txt, 28, 'left', "outline.ttf");
		txt.cameras = [camMain];

		var box = new UISliceSprite(textX - 12, textY + i * textSep - 6, 292, txt.height + 12, "button");
		box.incorporeal = true;
		box.cameras = [camMain];

		boxes.push(box);
		texts.push(txt);

		add(box);
		add(txt);
	}

	levelNameText = new FlxText(panelX + 24, panelY + 28, panelWidth - 48, "");
	JamUtils.setupText(levelNameText, 48, 'center', "outline.ttf");
	levelNameText.cameras = [camMain];
	add(levelNameText);

	artistText = new FlxText(panelX + 24, panelY + 112, panelWidth - 48, "");
	JamUtils.setupText(artistText, 24, 'center', "Small.otf");
	artistText.cameras = [camMain];
	add(artistText);

	deathCounter = new FlxText(panelX + 24, panelY + panelHeight - 150, panelWidth / 2 - 36, "Deaths: ");
	JamUtils.setupText(deathCounter, 36, 'center', "Small.otf");
	deathCounter.cameras = [camMain];
	add(deathCounter);

	timeCounter = new FlxText(panelX + panelWidth / 2, panelY + panelHeight - 150, panelWidth / 2, "");
	JamUtils.setupText(timeCounter, 36, 'center', 'Small.otf');
	timeCounter.cameras = [camMain];
	add(timeCounter);

	bar = new FlxBar(panelX + 24, panelY + panelHeight - 64, FlxBarFillDirection.LEFT_TO_RIGHT, panelWidth - 48, 30, null, null, 0, 3);

	bar.createFilledBar(0xff0f0f0f, 0xFFE9E9E9);
	bar.cameras = [camMain];
	add(bar);

	resetText = new FlxText(panelX + 24, panelY + panelHeight - 66, panelWidth - 48, "Hold Ctrl To Reset");

	JamUtils.setupText(resetText, 26, 'center', 'Small.otf');
	resetText.cameras = [camMain];
	add(resetText);
	chatBox = new UISliceSprite(0, 0, 1, 1, "button");
	chatBox.cameras = [camMain];
	chatBox.alpha = 0;
	chatBox.incorporeal = true;
	add(chatBox);

	typing.x = doll.x + 64 + 24;
	typing.y = doll.y - 186 - 64;
	JamUtils.setupText(typing, 32, 'center', 'small.otf');
	typing.cameras = [camMain];
	typing.sounds = [FlxG.sound.load(Paths.sound("talkSounds/talkF"))];
	add(typing);

	updateLevelInfo();
	changeSelect(0);
}

function showRandomChat() {
	var message = randomChat.exists(levels[curSelected]) && levels[curSelected] != "???" ? randomChat.get(levels[curSelected]) : "I don't have anything to say about this level.";

	typing.resetText(message, 0.05);
	typing.updateHitbox();

	chatBox.setPosition(typing.x - 12, typing.y - 12);
	chatBox.resize(typing.width + 12, typing.height + 24);

	typing.start();
	chatBox.alpha = 1;
}

function setupMenu() {
	panelX = FlxG.width / 2 - 12;
	panelWidth = FlxG.width / 2;
	panelHeight = FlxG.height - 24;

	var box = new UISliceSprite(panelX, panelY, panelWidth, panelHeight, "button");
	box.incorporeal = true;
	box.cameras = [camMain];

	boxesUI.push(box);
	add(box);

	icon = new FlxSprite(panelX + 12 + 86, panelY + 24 + 128).loadGraphic(Paths.image("levels/default"));
	icon.setGraphicSize(488 / 1.5, 488 / 1.5);
	icon.updateHitbox();
	icon.cameras = [camMain];
	icon.x = panelX + (panelWidth - icon.width) / 2;
	add(icon);

	stageText = new FlxText(panelX + 24, icon.y + icon.height + 12, panelWidth - 48, "< Stage: " + curStage + "/" + maxStage + " >");
	JamUtils.setupText(stageText, 32, 'center', "outline.ttf");
	stageText.cameras = [camMain];
	add(stageText);

	modeText = new FlxText(panelX + 24, icon.y + icon.height + 60, panelWidth - 48, "");
	JamUtils.setupText(modeText, 32, 'center', "outline.ttf");
	modeText.cameras = [camMain];
	add(modeText);

	modeHintText = new FlxText(panelX + 24, modeText.y + 32, panelWidth - 48, "Press SHIFT to change");
	JamUtils.setupText(modeHintText, 20, 'center', "Small.otf");
	modeHintText.cameras = [camMain];
	modeHintText.visible = FlxG.save.data.beatlevel3;
	add(modeHintText);

	doll = new FlxSprite();
	doll.frames = Paths.getSparrowAtlas('characters/doll');

	doll.animation.addByPrefix("idle0", "idle0", 12, true);
	doll.animation.addByPrefix("idle1", "idle1", 12, true);
	doll.animation.addByPrefix("idle2", "idle2", 12, true);
	doll.animation.play("idle" + FlxG.random.int(0, 2));

	doll.scale.set(0.55, 0.55);
	doll.flipX = true;
	doll.updateHitbox();
	doll.x -= doll.width / 4 - 20;
	doll.y = FlxG.height;
	doll.y -= doll.height;

	doll.cameras = [camMain];
	baseScaleY = doll.scale.y;
	baseScaleX = doll.scale.x;
	add(doll);
}

function updateIcon() {
	var graphic = Paths.image("levels/" + levels[curSelected]);

	if (!Assets.exists(Paths.image("levels/" + levels[curSelected])))
		graphic = Paths.image("levels/default");

	icon.loadGraphic(graphic);
}

function updateMode() {
	if (!Assets.exists(Paths.xml("levels/" + levels[curSelected]))) {
		modeText.text = "???";

		return;
	}
	var xml = Xml.parse(Assets.getText(Paths.xml("levels/" + levels[curSelected]))).firstElement();

	var leftAi = Std.parseInt(xml.get("leftAi") ?? "0");
	var rightAi = Std.parseInt(xml.get("rightAi") ?? "0");
	var backAi = Std.parseInt(xml.get("backAi") ?? "0");
	var upAi = Std.parseInt(xml.get("upAi") ?? "0");

	var hasAI = leftAi > 0 || rightAi > 0 || backAi > 0 || upAi > 0;

	isLevelPlatformer = !hasAI;
	modeText.text = isLevelPlatformer ? "Platformer Mode" : "Office Mode";
}

function setupCameras() {
	camMain = FlxG.camera;

	camBg.bgColor = FlxColor.BLACK;
	camBg.alpha = 1;

	FlxG.cameras.insert(camBg, 0, false);

	camMain.bgColor = FlxColor.TRANSPARENT;

	if (FlxG.save.data.bg)
		camBg.addShader(backgroundShader);
}

function setupBackground() {
	bg = new FlxBackdrop(Paths.image('game/square'), FlxAxes.XY, 0, 0);
	bg.setGraphicSize(FlxG.width, FlxG.height);
	bg.updateHitbox();
	bg.velocity.set(-30, 7.5);
	bg.alpha = 0.95;
	bg.color = 0xFFea76cd;
	bg.cameras = [camMain];

	if (FlxG.save.data.bg)
		bg.shader = blur;

	add(bg);

	vignette = new FlxSprite().loadGraphic(Paths.image("game/vignette"));
	vignette.setGraphicSize(FlxG.width, FlxG.height);
	vignette.updateHitbox();
	vignette.screenCenter();
	vignette.cameras = [camMain];

	add(vignette);
}

function update(elapsed:Float) {
	time += elapsed;
	backgroundShader.iTime = time;

	if (controls.DOWN_P && !active)
		changeSelect(1);
	if (controls.RIGHT_P && !active && levels[curSelected] != "???")
		changeStage(1);
	if (controls.LEFT_P && !active && levels[curSelected] != "???")
		changeStage(-1);

	if (FlxG.keys.pressed.CONTROL && !active) {
		resetTimer += elapsed;

		if (resetTimer > 3) {
			DeathCounter.reset(levels[curSelected]);
			CoolUtil.playMenuSFX(2, 1);
			resetTimer = 0;
		}
	}

	if (FlxG.keys.justReleased.CONTROL && !active)
		resetTimer = 0;

	bar.value = resetTimer;

	intendedTime = DeathCounter.loadBestTime(levels[curSelected]);
	lerpTime = Math.floor(FlxMath.lerp(intendedTime, lerpTime, Math.exp(-elapsed * 24)));

	intendedDeath = DeathCounter.loadBestDeaths(levels[curSelected]);
	lerpDeath = Math.floor(FlxMath.lerp(intendedDeath, lerpDeath, Math.exp(-elapsed * 24)));

	doll.scale.y = CoolUtil.fpsLerp(doll.scale.y, baseScaleY, 0.15);
	doll.scale.x = CoolUtil.fpsLerp(doll.scale.x, baseScaleX, 0.15);

	if (controls.UP_P && !active)
		changeSelect(-1);

	if (FlxG.keys.justPressed.SHIFT && !active && FlxG.save.data.beatlevel3) {
		isLevelPlatformer = !isLevelPlatformer;
		modeText.text = isLevelPlatformer ? "Platformer Mode" : "Office Mode";
		CoolUtil.playMenuSFX(0, 1);
	}
	if (doll.overlapsPoint(FlxG.mouse.getWorldPosition()) && FlxG.mouse.justPressed) {
		doll.scale.y = baseScaleY + 0.10;
		doll.scale.x = baseScaleX - 0.10;
		boop.pitch = FlxG.random.float(1, 2);
		boop.play();
		showRandomChat();
	}

	if (FlxG.keys.justPressed.ENTER && !active) {
		if (levels[curSelected] != "???") {
			CoolUtil.playMenuSFX(1, 1);

			if (isLevelPlatformer) {
				FlxG.switchState(new ModState("PlatformerState", {
					level: levels[curSelected],
					isStoryMode: false,
					stage: curStage,
					comingBack: curStage != 0
				}));
			} else {
				FlxG.switchState(new ModState("OfficeState", {
					level: levels[curSelected],
					isStoryMode: false,
					stage: curStage,
					comingBack: curStage != 0
				}));
			}
		} else {
			CoolUtil.playMenuSFX(2, 1);
			return;
		}
	}

	if (controls.BACK) {
		CoolUtil.playMenuSFX(2, 1);
		FlxG.switchState(new MainMenuState());
	}

	deathCounter.text = "Deaths: " + lerpDeath;
	timeCounter.text = "Best time: " + CoolUtil.timeToStr(lerpTime);
}

function updateLevelInfo() {
	if (!Assets.exists(Paths.xml("levels/" + levels[curSelected]))) {
		levelNameText.text = "Song not unlocked yet";
		artistText.text = "Beat previous level to unlock";
		return;
	}
	var xml = Xml.parse(Assets.getText(Paths.xml("levels/" + levels[curSelected]))).firstElement();

	var name = xml.get("name") ?? levels[curSelected];
	var bpm = xml.get("bpm") ?? "???";
	var artist = xml.get("artist") ?? "Unknown";
	for (node in xml.elements()) {
		switch (node.nodeName) {
			case "stages":
				for (stageNode in node.elements()) {
					maxStage++;
				}
		}
	}

	levelNameText.text = name + " (" + bpm + " bpm)";
	artistText.text = "By " + artist;
}

function changeSelect(cur:Int) {
	active = true;
	curSelected = FlxMath.wrap(curSelected + cur, 0, levels.length - 1);
	if (Assets.exists(Paths.image("levels/" + levels[curSelected])))
		icon.loadGraphic(Paths.image("levels/" + levels[curSelected]));
	else
		icon.loadGraphic(Paths.image("levels/default"));

	intendedTime = 0;
	intendedDeath = 0;

	lerpTime = 0;
	lerpDeath = 0;

	maxStage = 0;
	curStage = 0;

	updateLevelInfo();
	if (FlxG.save.data.beatlevel3)
	updateMode();

	CoolUtil.playMenuSFX(0, 1);

	for (i in 0...texts.length) {
		var targetY = textY + (i - curSelected) * textSep;

		FlxTween.tween(texts[i], {
			y: targetY
		}, 0.20, {
			ease: FlxEase.quartOut
		});

		FlxTween.tween(boxes[i], {
			y: targetY - 6
		}, 0.20, {
			ease: FlxEase.quartOut
		});

		texts[i].color = i == curSelected ? FlxColor.YELLOW : FlxColor.WHITE;
		boxes[i].framesOffset = i == curSelected ? 9 : 0;
	}

	stageText.text = "< Stage: " + (curStage + 1) + "/" + maxStage + " >";
	new FlxTimer().start(0.20, function(_) {
		active = false;
	});
}

function changeStage(cur:Int) {
	active = true;
	curStage = FlxMath.wrap(curStage + cur, 0, maxStage - 1);
	stageText.text = "< Stage: " + (curStage + 1) + "/" + maxStage + " >";

	CoolUtil.playMenuSFX(0, 1);

	new FlxTimer().start(0.20, function(_) {
		active = false;
	});
}
