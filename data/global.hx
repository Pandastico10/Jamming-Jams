import funkin.backend.utils.ShaderResizeFix; // script by 
import openfl.system.Capabilities; // script by care
import JamUtils;

static var JamUtils = new JamUtils();

function update(elapsed){
    if (FlxG.keys.justPressed.X) FlxG.switchState(new ModState("Test"));
    if (FlxG.keys.justPressed.G) FlxG.switchState(new ModState("PlatformerState"));
}

function new() {
    FlxG.save.bind("Save data", "Jamming Jams");
    FlxG.save.data.performance ??= false;
    FlxG.save.data.shaders ??= true;
    FlxG.save.data.freeplayUnlocked ??= false;
     FlxG.save.data.editorUnlocked ??= false;
    //legit no idea what i wanted to do with this
    FlxG.save.data.bgs ??= false;
    FlxG.save.flush();
    windowShit(1024, 768); // script by care
}
function destroy() {
    windowShit(1280, 720); // script by care
}
public static var winWidth = Math.floor(Capabilities.screenResolutionX * (3 / 4)) > Capabilities.screenResolutionY ? Math.floor(Capabilities.screenResolutionY * (4 / 3)) : Capabilitities.screenResolutionX; // script by care
public static var winHeight = Math.floor(Capabilities.screenResolutionX * (3 / 4)) > Capabilities.screenResolutionY ? Capabilities.screenResolutionY : Math.floor(Capabilities.screenResolutionX * (3 / 4)); // script by care

public static function windowShit(newWidth:Int, newHeight:Int){ // script by care
     if(newWidth == 1024 && newHeight == 768) // script by care
        FlxG.resizeWindow(winWidth * 0.9, winHeight * 0.9); // script by care
    else // script by care
        FlxG.resizeWindow(newWidth, newHeight); // script by care
    FlxG.resizeGame(newWidth, newHeight); // script by care
    FlxG.scaleMode.width = FlxG.width = FlxG.initialWidth = newWidth; // script by care
    FlxG.scaleMode.height = FlxG.height = FlxG.initialHeight = newHeight; // script by care
    ShaderResizeFix.doResizeFix = true; // script by care
    ShaderResizeFix.fixSpritesShadersSizes(); // script by care
    window.x = Capabilities.screenResolutionX/2 - window.width/2; // script by care
    window.y = Capabilities.screenResolutionY/2 - window.height/2; // script by care
} // script by care