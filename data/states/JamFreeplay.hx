import openfl.display.BlendMode;
import flixel.addons.display.FlxBackdrop;
import flixel.text.FlxText.FlxTextBorderStyle;
import funkin.editors.EditorPicker;
import funkin.editors.EditorTreeMenu;
import funkin.menus.ModSwitchMenu;
import funkin.options.OptionsMenu;
import funkin.backend.chart.Chart;
import funkin.editors.ui.UISliceSprite;
import funkin.savedata.FunkinSave;
import platformer.DeathCounter;
import Xml;

// menu options
var texts:Array<FlxText> = [];
var deathCounter:FlxText;
var timeCounter:FlxText;
var curSelected:Int = 0;
var levels:Array<String> = JamUtils.getList();
var textX:Int = 125;
var textY:Int = 85;
var textSep:Int = 62.5;
var scanline = new CustomShader('scanline');

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
	changeSelect(0);
	texts[0].color = FlxColor.YELLOW;
	// trace(FlxG.save.data.level0_bestTime);
}

function update(elapsed:Float) {
	if (FlxG.keys.justPressed.DOWN || FlxG.keys.justPressed.RIGHT)
		changeSelect(1);
	if (FlxG.keys.justPressed.UP || FlxG.keys.justPressed.LEFT)
		changeSelect(-1);
	if (FlxG.keys.justPressed.ENTER) {
		var xml = Xml.parse(Assets.getText(Paths.xml("levels/" + levels[curSelected]))).firstElement();
		var ai = Std.parseInt(xml.get("aiLvl"));
		if (ai == 0) {
			FlxG.switchState(new ModState("PlatformerState", levels[curSelected]));
		} else {
			FlxG.switchState(new ModState("OfficeState", levels[curSelected]));
		}
	}
	if (controls.BACK)
		FlxG.switchState(new MainMenuState());
	deathCounter.text = "Deaths: " + DeathCounter.load(levels[curSelected]);
	timeCounter.text = "Best time: " + CoolUtil.timeToStr(DeathCounter.loadBestTime(levels[curSelected]));
}

function changeSelect(cur:Int) {
	var temp = curSelected;
	curSelected = FlxMath.wrap(curSelected + cur, 0, levels.length - 1);
	CoolUtil.playMenuSFX(0, 1);
	for (i in 0...texts.length) {
		if (i == curSelected)
			texts[i].color = FlxColor.YELLOW;
		else
			texts[i].color = FlxColor.WHITE;
	}

	// deathCounter.text = "Deaths: "+ DeathCounter.load(levels[curSelected]);
}

function getBool(i:Int) {
	if (unlocked[i] == true)
		return true
	else
		return false;
}
