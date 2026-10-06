import funkin.backend.MusicBeatSubstate;
import funkin.options.TreeMenuScreen;
import funkin.options.type.NewOption;
import funkin.options.type.TextOption;
import funkin.editors.ui.UIState;
import haxe.io.Path;
import Xml;

var levels:Array<String>;
var menu:TreeMenuScreen;

function create() {
	levels = JamUtils.getList();

	var options:Array<FlxSprite> = [];

	for (level in levels)
		options.push(makeStageOption(level));

	options.push(new NewOption("Create New Level", "Create new level here", () -> {
		openSubState(new ModSubState("LevelCreatorScreen", {
			onSave: function(name:String) {
				levels.push(name);
				menu.insert(menu.members.length - 1, makeStageOption(name));
			}
		}));
	}));

	//jesus christ i had to separate EVERYTHING
	menu = new TreeMenuScreen("Level Editor", "Select a level to edit", null, options);
	addMenu(menu);
}
function makeStageOption(stage:String):TextOption {
	return new TextOption(stage, '', '', () -> {
		var xml = Xml.parse(Assets.getText(Paths.xml('levels/' + stage)));

		CoolUtil.safeSaveFile(Paths.getAssetsRoot() + '/data/levels/current.xml', xml);

		FlxG.switchState(new UIState(true, 'LevelEditor'));
	});
}
