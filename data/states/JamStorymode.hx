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
var textX:Int = 125;
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

function create() {
	CoolUtil.playMenuSong();

	levels.push("Quarter Circle");
	levels.push(FlxG.save.data.beatlevel1 ? "Lady's Locker Room" : "???");
	levels.push(FlxG.save.data.beatlevel2 ? "Dj's Mix" : "???");
	levels.push(FlxG.save.data.beatlevel3 ? "Perreo Heart" : "???");
	levels.push(FlxG.save.data.beatlevel4 ? "Last man Standing" : "???");

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

	updateLevelInfo();
	changeSelect(0);
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

	icon = new FlxSprite(panelX + 12 + 86, panelY + 24 + 158).loadGraphic(Paths.image("levels/default"));
	icon.setGraphicSize(488 / 1.25, 488 / 1.25);
	icon.updateHitbox();
	icon.cameras = [camMain];
	icon.x = panelX + (panelWidth - icon.width) / 2;
	add(icon);
}

function updateIcon() {
	var graphic = Paths.image("levels/" + levels[curSelected]);

	if (!Assets.exists(Paths.image("levels/" + levels[curSelected])))
		graphic = Paths.image("levels/default");

	icon.loadGraphic(graphic);
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

	if (controls.UP_P && !active)
		changeSelect(-1);

	if (FlxG.keys.justPressed.ENTER && !active) {
		if (levels[curSelected] != "???") {
			CoolUtil.playMenuSFX(1, 1);
			updateMode();

			if (isLevelPlatformer) {
				FlxG.switchState(new ModState("PlatformerState", {
					level: levels[curSelected],
					isStoryMode: true,
					stage: curStage
				}));
			} else {
				FlxG.switchState(new ModState("OfficeState", {
					level: levels[curSelected],
					isStoryMode: true,
					stage: curStage
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

	new FlxTimer().start(0.20, function(_) {
		active = false;
	});
}
function updateMode() {
	var xml = Xml.parse(Assets.getText(Paths.xml("levels/" + levels[curSelected]))).firstElement();

	var leftAi = Std.parseInt(xml.get("leftAi") ?? "0");
	var rightAi = Std.parseInt(xml.get("rightAi") ?? "0");
	var backAi = Std.parseInt(xml.get("backAi") ?? "0");
	var upAi = Std.parseInt(xml.get("upAi") ?? "0");

	var hasAI = leftAi > 0 || rightAi > 0 || backAi > 0 || upAi > 0;

	isLevelPlatformer = !hasAI;
}