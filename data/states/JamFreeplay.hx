import openfl.display.BlendMode;
import flixel.addons.display.FlxBackdrop;
import flixel.text.FlxText.FlxTextBorderStyle;
import funkin.editors.EditorPicker;
import funkin.editors.EditorTreeMenu;
import flixel.ui.FlxBar;
import flixel.ui.FlxBar.FlxBarFillDirection;
import funkin.menus.ModSwitchMenu;
import funkin.options.OptionsMenu;
import funkin.editors.ui.UISliceSprite;
import platformer.DeathCounter;
import Xml;

// menu options
var texts:Array<FlxText> = [];
var deathCounter:FlxText;
var timeCounter:FlxText;
var resetText:FlxText;
var bar:FlxBar;
var resetTimer:Float = 0;
var curSelected:Int = 0;
var levels:Array<String> = JamUtils.getList();
var textX:Int = 125;
var textY:Int = FlxG.height / 2;
var textSep:Int = 62.5;
var scanline = new CustomShader('scanline');
var active:Bool = false;

function create() {
	CoolUtil.playMenuSong();
	if (FlxG.save.data.shaders) {
		FlxG.camera.addShader(scanline);
	}
	for (i in 0...levels.length) {
		var txt = new FlxText(textX, textY + i * textSep, FlxG.width, levels[i]);
		add(txt);
		JamUtils.setupText(txt, 20, 'left', "Small.otf");
		texts.push(txt);
	}
	deathCounter = new FlxText(0, FlxG.height - 48, FlxG.width, "Deaths: ");
	JamUtils.setupText(deathCounter, 48, 'left', "Small.otf");
	add(deathCounter);
	timeCounter = new FlxText(FlxG.width - 320, FlxG.height - 48, FlxG.width, "");
	JamUtils.setupText(timeCounter, 48, 'left', 'Small.otf');
	add(timeCounter);
	resetText = new FlxText(0, FlxG.height - 48, FlxG.width, "Hold Ctl To reset");
	JamUtils.setupText(resetText, 48, 'center', 'Small.otf');

	bar = new FlxBar(FlxG.width / 2 - resetText.width / 8, FlxG.height - 30, FlxBarFillDirection.LEFT_TO_RIGHT, 260, 30, null, null, 0, 3);
	bar.createFilledBar(0xff0f0f0f, 0xFFE9E9E9);
	add(bar);
	add(resetText);

	changeSelect(0);
	texts[0].color = FlxColor.YELLOW;
	// trace(FlxG.save.data.level0_bestTime);
}

function update(elapsed:Float) {
	if ((FlxG.keys.justPressed.DOWN || FlxG.keys.justPressed.RIGHT) && active == false)
		changeSelect(1);
	if (FlxG.keys.pressed.CONTROL && active == false) {
		resetTimer += elapsed;
		if (resetTimer > 3) {
			DeathCounter.reset(levels[curSelected]);
			resetTimer = 0;
		}
	}
	if (FlxG.keys.justReleased.CONTROL && active == false)
		resetTimer = 0;
	bar.value = resetTimer;
	if ((FlxG.keys.justPressed.UP || FlxG.keys.justPressed.LEFT) && active == false)
		changeSelect(-1);
	if (FlxG.keys.justPressed.ENTER) {
		var xml = Xml.parse(Assets.getText(Paths.xml("levels/" + levels[curSelected]))).firstElement();

		var leftAi = Std.parseInt(xml.get("leftAi") ?? "0");
		var rightAi = Std.parseInt(xml.get("rightAi") ?? "0");
		var backAi = Std.parseInt(xml.get("backAi") ?? "0");
		var upAi = Std.parseInt(xml.get("upAi") ?? "0");

		var hasAI = leftAi > 0 || rightAi > 0 || backAi > 0 || upAi > 0;

		if (hasAI) {
			FlxG.switchState(new ModState("OfficeState", levels[curSelected]));
		} else {
			FlxG.switchState(new ModState("PlatformerState", levels[curSelected]));
		}
	}
	if (controls.BACK)
		FlxG.switchState(new MainMenuState());
	deathCounter.text = "Deaths: " + DeathCounter.load(levels[curSelected]);
	timeCounter.text = "Best time: " + CoolUtil.timeToStr(DeathCounter.loadBestTime(levels[curSelected]));
}

function changeSelect(cur:Int) {
	active = true;
	curSelected = FlxMath.wrap(curSelected + cur, 0, levels.length - 1);
	CoolUtil.playMenuSFX(0, 1);
	for (i in 0...texts.length) {
		FlxTween.tween(texts[i], {y: textY + (i - curSelected) * textSep}, 0.20, {
			ease: FlxEase.quartOut
		});
		texts[i].color = i == curSelected ? FlxColor.YELLOW : FlxColor.WHITE;
	}
	new FlxTimer().start(0.20, function(_) {
		active = false;
	});
}

// yeah man
function getBool(i:Int) {
	if (unlocked[i] == true)
		return true
	else
		return false;
}
