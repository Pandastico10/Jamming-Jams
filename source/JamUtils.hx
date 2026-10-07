package source;
import haxe.io.Path;

class JamUtils {
	public function getList():Array<String> {
		var list:Array<String> = [];

		for (path in Paths.getFolderContent("data/levels/", false)) {
			var extension = Path.extension(path);

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
    public function startDialogue(typing:FunkinTypeText, file:String, ?startIndex:Int = 0)
    {
        var dialogues:Array<Dynamic> = Json.parse(Assets.getText(Paths.json(file)));
        var typeList:Array<TypeTextItem> = [];
        for (d in dialogues)
        {
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
    public function setupText(text:FlxText, ?size:Int = 72, ?alignment:String = "center")
    {
        if (size == null)
        size = 72;

    if (alignment == null)
        alignment = "center";
    text.font = Paths.font("wondermail.ttf");
    text.size = size;
    text.color = FlxColor.WHITE;
    text.alignment = alignment;
    text.setBorderStyle(FlxTextBorderStyle.SHADOW,FlxColor.BLACK,2.5,1);
    }
}
