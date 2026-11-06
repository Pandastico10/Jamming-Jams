import FunkinTypeText;
import haxe.io.Path;
import flixel.text.FlxText.FlxTextBorderStyle;

class JamUtils {
	public function getList(?excludeStory:Bool = false):Array<String> {
		var list:Array<String> = [];

		//yes on EVERYONES SOUL we hardcoding levels
		for (path in Paths.getFolderContent("data/levels/", false)) {
			var extension = Path.extension(path);
			if (excludeStory
				&& (path == "Quarter Circle.xml" || path == "Lady's Locker Room.xml" || path == "Dj's Mix.xml" || path == "Perreo Heart.xml"|| path == "Last man Standing.xml"))
				continue;
			if (extension == "xml" && path != "current.xml")
				list.push(Path.withoutExtension(path));
		}

		return list;
	}

	/**
	 * Function to make it easier to start an change dialogue using FunkinTypeText
	 * * Example: JamUtils.startDialogue(typing, "json/quiz/intro", 1);
	 * @param typing Name of the FunkinTypeText class
	 * @param file Json path for the dialogue
	 * @param startIndex Delay for the start of the dialogue
	 */
	public function startDialogue(typing:FunkinTypeText, file:String, ?startIndex:Int = 0) {
		var dialogues:Array<Dynamic> = Json.parse(Assets.getText(Paths.json(file)));
		var typeList:Array<TypeTextItem> = [];
		for (d in dialogues) {
			typeList.push(TypeTextItem.fromJson(d));
		}

		typing.resetList(typeList);
		typing.start(startIndex);
	}

	/**
	 * Automatically sets text to use the Wondermail font.
	 *
	 * * Example: JamUtils.setupText(myText, 48, "center");
	 *
	 * @param text FlxText object to format
	 * @param size Size of the text
	 * @param alignment Text alignment ("center" or "left")
	 */
	public function setupText(text:FlxText, ?size:Int = 72, ?alignment:String = "center", ?font:String = "outline.ttf") {
		if (size == null)
			size = 72;

		if (alignment == null)
			alignment = "center";

		if (font == null)
			font = "outline.ttf";

		text.setFormat(Paths.font(font), size, FlxColor.WHITE, alignment);
		text.setBorderStyle(FlxTextBorderStyle.SHADOW, FlxColor.BLACK, 2.5, 1);
	}
}
