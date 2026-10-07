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
var options:Array<String> = ["Story Mode", "Freeplay", "Options", "Credits", "Level Editor"];
var unlocked:Array<Bool> = [true, false, true, true, false];
var texts:Array<FlxText> = [];
var curSelected:Int = 0;

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
	// if (FlxG.save.data.freeplayUnlocked)
		unlocked[1] = true;
	if (FlxG.save.data.editorUnlocked)
		unlocked[4] = true;

	for (i in 0...options.length) {
		var txt = new FlxText(textX, textY + i * textSep, FlxG.width, options[i]);
		add(txt);
		texts.push(txt);
	}
    changeSelect(0);
	texts[0].color = FlxColor.YELLOW;
}

function update(elapsed:Float) {
	if (controls.SWITCHMOD) {
		persistentUpdate = !(persistentDraw = true);
		openSubState(new ModSwitchMenu());
	}
	if (FlxG.keys.justPressed.SEVEN) {
		persistentUpdate = !(persistentDraw = true);
		openSubState(new EditorPicker());
	}
	if (FlxG.keys.justPressed.DOWN || FlxG.keys.justPressed.RIGHT)
		changeSelect(1);
	if (FlxG.keys.justPressed.UP || FlxG.keys.justPressed.LEFT)
		changeSelect(-1);
    if (FlxG.keys.justPressed.ENTER) {
		switch (options[curSelected]) {
			case "Story Mode":
				FlxG.switchState(new ModState("JamStorymode"));
			case "Freeplay":
				FlxG.switchState(new ModState("JamFreeplay"));
			case "Options":
				FlxG.switchState(new OptionsMenu());
			case "Credits":
				FlxG.switchState(new ModState("JamCredits"));
            case "Level Editor":
				FlxG.switchState(new EditorTreeMenu(null, true, "LevelSelector"));
		}
	}
}

function changeSelect(cur:Int) {
    var temp = curSelected;
    //wish there was a better way to do this :SOB:
	texts[0].color = FlxColor.WHITE;
	texts[1].color = FlxG.save.data.freeplayUnlocked ? FlxColor.WHITE : FlxColor.RED;
	texts[2].color = FlxColor.WHITE;
	texts[3].color = FlxColor.WHITE;
	texts[4].color = FlxG.save.data.editorUnlocked ? FlxColor.WHITE : FlxColor.RED;
	curSelected = FlxMath.wrap(curSelected + cur, 0, options.length - 1);
	if (getBool(curSelected) == false)
		curSelected = FlxMath.wrap(curSelected + cur, 0, options.length - 1);
	CoolUtil.playMenuSFX(0, 1);
	texts[curSelected].color = FlxColor.YELLOW;
    FlxTween.cancelTweensOf(texts[temp]);
    FlxTween.tween(texts[temp],{x: textX}, 0.35,{ease: FlxEase.cubeOut});
    FlxTween.tween(texts[curSelected],{x: textX + 25}, 0.35,{ease: FlxEase.cubeOut});
}

function getBool(i:Int) {
	if (unlocked[i] == true)
		return true
	else
		return false;
}
