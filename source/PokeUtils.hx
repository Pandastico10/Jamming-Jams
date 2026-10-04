import openfl.net.URLLoader;
import openfl.net.URLLoaderDataFormat;
import openfl.net.URLRequest;
import openfl.display.BitmapData;
import sys.io.File;
import sys.FileSystem;
import Xml;
import haxe.xml.Access;
import FunkinTypeText;
import flixel.text.FlxText.FlxTextBorderStyle;

/**
 * Custom class made for the Sing for the sky mod
 */
class PokeUtils{

    
    /**
    * Load portrait from the PMDSpriters Repo, if it doesnt exist, it will download the image first, will only show the icon if the icon is downloaded already
    * * Example: icon.loadGraphic(PokeUtils.loadIcon("0447", "Normal"));
    * @param index National dex number of the pokemon
    * @param emotion Name of the emotion of the icon (not all pokemon have all emotions)
    * @return BitmapData the data for the sprite
    */
    public function loadIcon(index:String, emotion:String):BitmapData
    {   
        var folderPath = Paths.getAssetsRoot() + "/images/sprites/" + index + "/";
        var savePath = folderPath + emotion + ".png";
        CoolUtil.addMissingFolders(folderPath);

        // if downloaded
        if (FileSystem.exists(savePath))
        {
            return BitmapData.fromFile(savePath);
        }

        // If not
        trace("Icon not found: " + savePath);
        trace("Downloading...");
        downloadSprite(index, emotion);

        return null;
    }
    /**
    * Download portrait from the PMDSpriters repo, will be called automatically in loadIcon but can also be called individually to download a batch
    * * Example: PokeUtils.downloadSprite("0447", "Normal");
    * @param index National dex number of the pokemon
    * @param emotion Name of the emotion of the icon (not all pokemon have all emotions)
    */
    public function downloadSprite(dex:String, spriteName:String)
    {
        var url = "https://raw.githubusercontent.com/PMDCollab/SpriteCollab/master/portrait/"+ dex + "/" + spriteName + ".png";
        var folderPath = Paths.getAssetsRoot() + "/images/sprites/" + dex + "/";
        var savePath = folderPath + spriteName + ".png";
        CoolUtil.addMissingFolders(folderPath);

        var loader = new URLLoader();
        loader.dataFormat = URLLoaderDataFormat.BINARY;
        loader.addEventListener("complete", function(_)
        {
            File.saveBytes(savePath, cast loader.data);
        });
        loader.addEventListener("ioError", function(e)
        {
            trace("Error downloading sprite: " + url);
        });
        loader.load(new URLRequest(url));
    }
    /**
     * Set up animations for an overworld sprite
     * * Example: PokeUtils.setupAnimations(player, 2, 10, 8);
     * @param spr Sprite to setup animations to
     * @param idlefps fps of the idle animation
     * @param walkfps fps of the walk animation
     * @param otherfps fps of other animations, such as waking up
     */
    public function setupAnimations(spr:FlxSprite, idlefps:Int, walkfps:Int, otherfps:Int) 
    {
        // idle
        spr.animation.addByPrefix("idleUp", "idle8", idlefps, true);
        spr.animation.addByPrefix("idleDown", "idle2", idlefps, true);
        spr.animation.addByPrefix("idleLeft", "idle4", idlefps, true);
        spr.animation.addByPrefix("idleRight", "idle6", idlefps, true);
        spr.animation.addByPrefix("idleUpLeft", "idle7", idlefps, true);
        spr.animation.addByPrefix("idleUpRight", "idle9", idlefps, true);
        spr.animation.addByPrefix("idleDownLeft", "idle1", idlefps, true);
        spr.animation.addByPrefix("idleDownRight", "idle3", idlefps, true);

        // walk
        spr.animation.addByPrefix("walkUp", "walk8", walkfps, true);
        spr.animation.addByPrefix("walkDown", "walk2", walkfps, true);
        spr.animation.addByPrefix("walkLeft", "walk4", walkfps, true);
        spr.animation.addByPrefix("walkRight", "walk6", walkfps, true);
        spr.animation.addByPrefix("walkUpLeft", "walk7", walkfps, true);
        spr.animation.addByPrefix("walkUpRight", "walk9", walkfps, true);
        spr.animation.addByPrefix("walkDownLeft", "walk1", walkfps, true);
        spr.animation.addByPrefix("walkDownRight", "walk3", walkfps, true);

        // lay
        spr.animation.addByPrefix("layLeft", "lay1", 1, false);
        spr.animation.addByPrefix("layRight", "lay2", 1, false);

        // wake
        spr.animation.addByPrefix("wakeLeft", "wake1", otherfps, false);
        spr.animation.addByPrefix("wakeRight", "wake2", otherfps, false);
    }

    /**
     * Function to make it easier to start an change dialogue using FunkinTypeText
     * * Example: PokeUtils.startDialogue(typing, "json/quiz/intro", 1);
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
     * * Example: PokeUtils.setupText(myText, 48, "center");
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