import flixel.addons.display.FlxBackdrop;
import funkin.editors.EditorPicker;
import funkin.editors.EditorTreeMenu;
import funkin.menus.ModSwitchMenu;
import funkin.options.OptionsMenu;
import funkin.editors.ui.UIState;
import funkin.editors.ui.UISliceSprite;
import FunkinTypeText;

var options:Array<String> = ["Story Mode", "Freeplay", "Options", "Credits", "Level Editor"];
var unlocked:Array<Bool> = [true, false, true, true, false];
var stars:Int = 0;

var optionsTexts:Array<String> = [
	"Experience the story and levels as it was intended, recommended on first play",
	"Replay all levels from story mode plus some extra ones! (Beating story mode levels in freeplay does not count for progression)",
	"Change the options and controls for the mod here (i didnt have time to finish this menu fully im sorry",
	"(Recomended after level 3) View the credits for people that worked and helped with the game",
	"Create or edit new levels"
];

var randomChat:Array<String> = [
	"I'm writing this at 3 AM currently. I hope it's worth it.\nRemember to always get your 8 hours of sleep.",
	"I've spent like half of the jam playing Frickbears 3 and slacking off i'm gonna be so fr.",
	"Currently deleting your System32 folder. I hope you don't mind.",
	"Hey, who's that behind you...\nHeh, made you look.",
	"Imagine having FNF gameplay in your Codename Engine mod. Couldn't be me.",
	"If by some chance you stumble upon my friend Maya, tell her she forgot to return my glasses.",
	"Can't believe I'm getting paid to talk to you...\nOh wait, I'm not getting paid.",
	"What? You actually expected me to tell you actual tips for the game?",
	"If at any point you feel like you've had enough, you can give up and try again later.",
	"All of this is canon, btw. You probably don't know what for, but it is.",
	"I'm just as confused as you are, buddy. How the hell did I get here?",
	"Also play Sing for the Sky when it releases.",
	"Avanza pe porfavor, Gracias.",
	"Who am I, you ask?\nYou'll learn that in due time.",
	"If I could be a cartoon character for 24 hours, I think I'd like to be Uncle Grandpa for a day.",
	"Yes, i rushed the hell out of this how could you tell?"
];

var randomBoop:Array<String> = [
	"Are you serious right now?",
	"How long are you gonna keep doing that?",
	"Don't touch me, im ticklish",
	"Okay, its getting kind of annoying now",
	"Boop",
	"Can we play the game already?"
];

var chatBox:UISliceSprite;
var typing:FunkinTypeText = new FunkinTypeText(0, 0, 256, 8);
var texts:Array<FlxText> = [];
var selectTexts:Array<FlxText> = [];
var boxes:Array<UISliceSprite> = [];
var selectBoxes:Array<UISliceSprite> = [];
var curSelected:Int = 0;
var selectTime:Float = 0.50;
var selectTimer:Float = 0;
var textX:Int = 125;
var textY:Int = 356;
var textSep:Int = 62;
var time:Float = 0;
var temp:Float = 0.25;
var delay:Float = 0.10;
var bg:FlxBackdrop;
var vignette:FlxSprite;
var logo:FlxSprite;
var logoBaseScaleX:Float;
var logoBaseScaleY:Float;
var doll:FlxSprite;
var baseScaleY:Float = 0;
var baseScaleX:Float = 0;
var scanline = new CustomShader('scanline');
var blur = new CustomShader('blur');
var backgroundShader = new CustomShader(FlxG.save.data.bgs);
var camBg:FlxCamera = new FlxCamera();
var camMain:FlxCamera = new FlxCamera();
var active:Bool = false;
var everyTwo:Bool = false;
var boops:Int = 0;
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
	FlxG.mouse.visible = true;

	if (FlxG.save.data.freeplayUnlocked)
		unlocked[1] = true;
	if (FlxG.save.data.editorUnlocked)
		unlocked[4] = true;

	if (FlxG.save.data.beatlevel1)
		stars++;
	if (FlxG.save.data.beatlevel2)
		stars++;
	if (FlxG.save.data.beatlevel3)
		stars++;
	if (FlxG.save.data.beatlevel4)
		stars++;
	if (FlxG.save.data.beatlevel5)
		stars++;

	setupCameras();
	setupBackground();
	setupMenu();

	chatBox = new UISliceSprite(0, 0, 1, 1, "button");
	chatBox.cameras = [camMain];
	chatBox.alpha = 0;
	chatBox.incorporeal = true;
	add(chatBox);

	typing.x = doll.x;
	typing.y = doll.y - 186;

	JamUtils.setupText(typing, 32, 'center', 'small.otf');
	typing.cameras = [camMain];
	typing.sounds = [FlxG.sound.load(Paths.sound("talkSounds/talkF"))];

	add(typing);

	new FlxTimer().start(delay * options.length, function(_) {
		active = true;
		showRandomChat();
	});
}

function showRandomChat() {
	typing.resetText(FlxG.random.getObject(randomChat), 0.05);
	typing.updateHitbox();
	chatBox.setPosition(typing.x - 16, typing.y - 12);
	chatBox.resize(typing.width + 32, typing.height + 24);
	typing.start();
	chatBox.alpha = 1;
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
	bg.velocity.set(-30, 7.5);
	bg.alpha = 0.95;
	bg.cameras = [camMain];
	bg.color = 0xFFea76cd;

	if (FlxG.save.data.shaders)
		bg.shader = blur;

	add(bg);

	logo = new FlxSprite(-200, -48).loadGraphic(Paths.image("menus/mainmenu/logo" + stars));
	logo.frames = Paths.getSparrowAtlas("menus/mainmenu/logo" + stars);
	logo.animation.addByPrefix("idle", "idle", 12, true);
	logo.animation.play("idle");
	logo.scale.set(0.5, 0.5);
	logo.alpha = 0;
	logo.cameras = [camMain];
	add(logo);

	logoBaseScaleX= logo.scale.x;
	logoBaseScaleY = logo.scale.y;

	doll = new FlxSprite();
	doll.frames = Paths.getSparrowAtlas('characters/doll');

	doll.animation.addByPrefix("idle0", "idle0", 12, true);
	doll.animation.addByPrefix("idle1", "idle1", 12, true);
	doll.animation.addByPrefix("idle2", "idle2", 12, true);
	doll.animation.play("idle" + FlxG.random.int(0, 2));

	doll.scale.set(0.55, 0.55);
	doll.updateHitbox();

	doll.x = FlxG.width - doll.width;
	doll.y = FlxG.height - doll.height;

	doll.cameras = [camMain];

	baseScaleY = doll.scale.y;
	baseScaleX = doll.scale.x;

	add(doll);

	var logoY = logo.y;
	logo.y = !FlxG.height - 350;
	FlxTween.tween(logo, {y: logoY, alpha: 1}, 2, {
		ease: FlxEase.backOut
	});

	vignette = new FlxSprite().loadGraphic(Paths.image("game/vignette"));
	vignette.setGraphicSize(FlxG.width, FlxG.height);
	vignette.screenCenter();
	vignette.cameras = [camMain];
	add(vignette);
}

function setupMenu() {
	if (FlxG.save.data.freeplayUnlocked)
		unlocked[1] = true;
	if (FlxG.save.data.editorUnlocked)
		unlocked[4] = true;

	for (i in 0...options.length) {
		var txt = new FlxText(textX, textY + i * textSep + 6, FlxG.width, options[i]);
		JamUtils.setupText(txt, 28, 'left', "outline.ttf");
		txt.cameras = [camMain];
		texts.push(txt);

		var box = new UISliceSprite(textX - 12, textY + i * textSep, 208, txt.height + 8, "button");
		box.incorporeal = true;
		box.cameras = [camMain];
		boxes.push(box);
		add(box);
		add(txt);
	}

	for (i in 0...optionsTexts.length) {
		var txt = new FlxText(textX + texts[i].x + 128, textY + i * textSep, 256, optionsTexts[i]);
		txt.alpha = 0;
		JamUtils.setupText(txt, 32, 'left', "Small.otf");
		txt.cameras = [camMain];
		selectTexts.push(txt);

		var box = new UISliceSprite(txt.x - 12, txt.y, 280, txt.height + 12, "button");
		box.incorporeal = true;
		box.alpha = 0;
		box.cameras = [camMain];
		selectBoxes.push(box);
		add(box);
		add(txt);
	}

	// changeSelect(0);
	for (i in 0...texts.length) {
		texts[i].color = getBool(i) ? FlxColor.WHITE : FlxColor.RED;
	}
	texts[0].color = FlxColor.YELLOW;

	for (i in 0...options.length) {
		texts[i].alpha = 0;
		boxes[i].alpha = 0;
		var targetX = texts[i].x;
		var targetX2 = boxes[i].x;
		texts[i].x = !FlxG.width - 50;
		boxes[i].x = !FlxG.width - 50;
		FlxTween.tween(texts[i], {x: targetX, alpha: 1}, 1, {
			ease: FlxEase.backOut,
			startDelay: temp
		});
		FlxTween.tween(boxes[i], {x: targetX2, alpha: 1}, 1, {
			ease: FlxEase.backOut,
			startDelay: temp
		});
		temp += delay;
	}
}

function update(elapsed:Float) {
	time += elapsed;
	backgroundShader.iTime = time;

	camMain.zoom = CoolUtil.fpsLerp(camMain.zoom, 1, 0.1);
	doll.scale.y = CoolUtil.fpsLerp(doll.scale.y, baseScaleY, 0.15);
	doll.scale.x = CoolUtil.fpsLerp(doll.scale.x, baseScaleX, 0.15);
	logo.scale.y = CoolUtil.fpsLerp(logo.scale.y, logoBaseScaleY, 0.15);
	logo.scale.x = CoolUtil.fpsLerp(logo.scale.x, logoBaseScaleX, 0.15);

	if (active)
		selectTimer += elapsed;

	if (selectTimer >= selectTime) {
		for (i in 0...optionsTexts.length) {
			var target:Float = i == curSelected ? 1 : 0;

			selectTexts[i].alpha = CoolUtil.fpsLerp(selectTexts[i].alpha, target, 0.1);
			selectBoxes[i].alpha = CoolUtil.fpsLerp(selectBoxes[i].alpha, target, 0.1);
		}
	}

	if (controls.SWITCHMOD) {
		persistentUpdate = !(persistentDraw = true);
		openSubState(new ModSwitchMenu());
	}

	if (FlxG.keys.justPressed.SEVEN) {
		persistentUpdate = !(persistentDraw = true);
		openSubState(new EditorPicker());
	}

	if ((controls.DOWN_P || controls.RIGHT_P) && active)
		changeSelect(1);

	if ((controls.UP_P || controls.LEFT_P) && active)
		changeSelect(-1);

	if (doll.overlapsPoint(FlxG.mouse.getWorldPosition()) && FlxG.mouse.justPressed) {
		doll.scale.y = baseScaleY + 0.10;
		doll.scale.x = baseScaleX - 0.10;
		boops++;
		boop.pitch = FlxG.random.float(1, 2);
		boop.play();
		if (boops % 5 == 0) {
			doll.animation.play("idle" + FlxG.random.int(0, 2));
			typing.resetText(FlxG.random.getObject(randomBoop));
			typing.start();
		}
	}

	if (controls.ACCEPT && active) {
		CoolUtil.playMenuSFX(1, 1);
		switch (options[curSelected]) {
			case "Story Mode":
				FlxG.switchState(new ModState("JamStorymode"));

			case "Freeplay":
				FlxG.switchState(new ModState("JamFreeplay"));

			case "Options":
				FlxG.switchState(new OptionsMenu());

			case "Credits":
				FlxG.switchState(new UIState(true, "JamCredits"));

			case "Level Editor":
				FlxG.switchState(new EditorTreeMenu(null, true, "LevelSelector"));
		}
	}
}

function measureHit(curMeasure:Int) {
	camMain.zoom += 0.03;
}
function beatHit(curBeat:Int) {
	if (active) {
		if (curBeat % 2 != 0)
			return;
		logo.scale.x += 0.03;
		logo.scale.y += 0.03;
	}
}

function changeSelect(cur:Int) {
	var previous = curSelected;

	selectTimer = 0;

	for (i in 0...selectTexts.length) {
		selectTexts[i].alpha = 0;
		selectBoxes[i].alpha = 0;
	}

	for (i in 0...texts.length) {
		texts[i].color = getBool(i) ? FlxColor.WHITE : FlxColor.RED;
	}

	curSelected = FlxMath.wrap(curSelected + cur, 0, options.length - 1);

	if (!getBool(curSelected))
		curSelected = FlxMath.wrap(curSelected + cur, 0, options.length - 1);

	CoolUtil.playMenuSFX(0, 1);

	boxes[curSelected].framesOffset = 9;
	boxes[previous].framesOffset = 0;

	texts[curSelected].color = FlxColor.YELLOW;

	FlxTween.cancelTweensOf(texts[previous]);
	FlxTween.cancelTweensOf(boxes[previous]);

	FlxTween.tween(texts[previous], {x: textX}, 0.35, {ease: FlxEase.cubeOut});
	FlxTween.tween(texts[curSelected], {x: textX + 25}, 0.35, {ease: FlxEase.cubeOut});

	FlxTween.tween(boxes[previous], {x: textX - 12}, 0.35, {ease: FlxEase.cubeOut});
	FlxTween.tween(boxes[curSelected], {x: textX + 13}, 0.35, {ease: FlxEase.cubeOut});
}

function getBool(i:Int):Bool {
	return unlocked[i];
}
