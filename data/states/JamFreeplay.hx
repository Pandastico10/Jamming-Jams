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

// menu options
var texts:Array<FlxText> = [];
var curSelected:Int = 0;
var levels:Array<String> = JamUtils.getList();
var textX:Int = 125;
var textY:Int = 85;
var textSep:Int = 62.5;

var what:Array<String> = [
	"Play the Main Story of the mod",
	"Check out treasure town and replay songs here!.",
	"Change your options here.",
	"Take the Personality Test again.",
	"Check out the mod's extra content!"
];

function create() {
	CoolUtil.playMenuSong();
	if (FlxG.save.data.freeplayUnlocked)
		unlocked[1] = true;
	if (FlxG.save.data.editorUnlocked)
		unlocked[4] = true;

	for (i in 0...levels.length) {
		var txt = new FlxText(textX, textY + i * textSep, FlxG.width, levels[i]);
		add(txt);
		texts.push(txt);
	}
	changeSelect(0);
	texts[0].color = FlxColor.YELLOW;
}

function update(elapsed:Float) {
	if (FlxG.keys.justPressed.DOWN || FlxG.keys.justPressed.RIGHT)
		changeSelect(1);
	if (FlxG.keys.justPressed.UP || FlxG.keys.justPressed.LEFT)
		changeSelect(-1);
	if (FlxG.keys.justPressed.ENTER) {
        trace(levels[curSelected]);
        FlxG.switchState(new ModState("PlatformerState", levels[curSelected]));
	}
    if (controls.BACK) FlxG.switchState(new MainMenuState());
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
}

function getBool(i:Int) {
	if (unlocked[i] == true)
		return true
	else
		return false;
}
