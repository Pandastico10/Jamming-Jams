import flixel.addons.display.FlxBackdrop;
import openfl.display.BlendMode;
import funkin.editors.ui.UISliceSprite;
import Type;

var boxWidth:Int = 760;
var boxHeight:Int = 100;

var customTexts:Array<FlxText> = [];
var customIcons:Array<FlxText> = [];

var currentScreen:Dynamic = null;

var camOptions:FlxCamera;
var camBg:FlxCamera = new FlxCamera();

var box:UISliceSprite;
var selector:FlxText;
var title:FlxText;
var bg:FlxBackdrop;
var vignette:FlxSprite;

var backgroundShader = new CustomShader(FlxG.save.data.bgs);
var blur = new CustomShader('blur');

var time:Float = 0;

var panelX:Float;
var panelY:Float;
var optionStartY:Float;

function postCreate() {
    
    CoolUtil.playMusic(Paths.music("Sakura-core"), false, 0.8, true, 112);
    

    camOptions = new FlxCamera();
    camOptions.bgColor = FlxColor.BLACK;
    FlxG.cameras.add(camOptions, false);

    titleLabel.cameras = [camOptions];
    descLabel.cameras = [camOptions];
    setupCameras();
    setupBackground();

    panelX = (FlxG.width - boxWidth) / 2;
    panelY = 70;
    optionStartY = panelY + 110;

    box = new UISliceSprite(panelX, panelY, boxWidth, boxHeight, "button");
    box.cameras = [camOptions];
    box.incorporeal = true;
    add(box);

    title = new FlxText(panelX + 32, panelY + 18, boxWidth - 64, "OPTIONS");
    JamUtils.setupText(title, 48, "center", "outline.ttf");
    title.cameras = [camOptions];
    add(title);

    selector = new FlxText(panelX + 24, optionStartY, 40, ">");
    JamUtils.setupText(selector, 42, "center", "outline.ttf");
    selector.cameras = [camOptions];
    add(selector);
}
function setupCameras() {
    camBg.bgColor = FlxColor.BLACK;
    camBg.alpha = 1;

    FlxG.cameras.insert(camBg, 1, false);

    camOptions.bgColor = FlxColor.TRANSPARENT;

    if (FlxG.save.data.bg)
        camBg.addShader(backgroundShader);
}

function setupBackground() {
    bg = new FlxBackdrop(Paths.image('game/square'), FlxAxes.XY, 0, 0);
    bg.setGraphicSize(FlxG.width, FlxG.height);
    bg.updateHitbox();
    bg.velocity.set(-30, 7.5);
    bg.alpha = 0.95;
    bg.color = 0xFFea76cd;
    bg.cameras = [camOptions];

    if (FlxG.save.data.bg)
        bg.shader = blur;

    add(bg);

    vignette = new FlxSprite().loadGraphic(Paths.image("game/vignette"));
    vignette.setGraphicSize(FlxG.width, FlxG.height);
    vignette.updateHitbox();
    vignette.screenCenter();
    vignette.cameras = [camOptions];

    add(vignette);
}

function update(elapsed:Float) {
    mouseControl = false;
    	time += elapsed;
	backgroundShader.iTime = time;
    var screen = tree[tree.length - 1];

    if (screen != currentScreen) {
        currentScreen = screen;
        rebuildCustomTexts(screen);
    }

    updateCustomValues(screen);

    time += elapsed;
    selector.x = panelX + 24 + Math.sin(time * 4) * 3;
}

function rebuildCustomTexts(screen:Dynamic) {
    for (text in customTexts) {
        remove(text);
        text.destroy();
    }

    for (icon in customIcons) {
        remove(icon);
        icon.destroy();
    }

    customTexts = [];
    customIcons = [];

    var textIndex:Int = 0;

    for (option in screen.members) {
        if (option == null)
            continue;

        var alphabet = Reflect.field(option, "__text");

        if (alphabet == null)
            continue;

        var textValue = Reflect.field(alphabet, "text");

        if (textValue == null)
            continue;

        var yPos:Float = optionStartY + textIndex * 48;

        var newText = new FlxText(panelX + 76, yPos, boxWidth - 280, textValue);
        JamUtils.setupText(newText, 30, "left", "outline.ttf");
        newText.cameras = [camOptions];
        add(newText);

        customTexts.push(newText);

        var icon = new FlxText(panelX + boxWidth - 160, yPos, 100, "");
        JamUtils.setupText(icon, 30, "center", "outline.ttf");
        icon.cameras = [camOptions];
        add(icon);

        customIcons.push(icon);

        textIndex++;
    }

    boxHeight = 110 + textIndex * 48;
    box.resize(boxWidth, boxHeight);

    selector.y = optionStartY;
}

function updateCustomValues(screen:Dynamic) {
    var textIndex:Int = 0;

    for (option in screen.members) {
        if (option == null)
            continue;

        var alphabet = Reflect.field(option, "__text");

        if (alphabet == null)
            continue;

        if (textIndex >= customTexts.length)
            continue;

        var optionName:String = Reflect.field(option, "optionName");
        var className:String = Type.getClassName(Type.getClass(option));

        var displayText:String = Reflect.field(alphabet, "text");

        var icon = customIcons[textIndex];

        if (className == "funkin.options.type.Checkbox") {
            var checked:Bool = Reflect.field(option, "checked");

            icon.text = checked ? "[X]" : "[ ]";

        } else if (className == "funkin.options.type.NumOption") {
            var value:Dynamic = Reflect.field(option, "currentValue");

            displayText += ": " + value;

            icon.text = "";

        } else if (className == "funkin.options.type.SliderOption") {
            var value:Dynamic = Reflect.field(option, "currentValue");

            displayText += ": " + CoolUtil.quantize(value, 100);

            icon.text = "";

        } else if (className == "funkin.options.type.ArrayOption") {
            var values:Dynamic = Reflect.field(option, "displayOptions");
            var selected:Dynamic = Reflect.field(option, "currentSelection");

            if (values != null)
                displayText += ": " + values[selected];

            icon.text = "< >";

        } else {
            icon.text = "";
        }

        customTexts[textIndex].text = displayText;

        var selected:Bool = Reflect.field(option, "selected");

        customTexts[textIndex].color = selected ? FlxColor.YELLOW : FlxColor.WHITE;
        icon.color = selected ? FlxColor.YELLOW : FlxColor.WHITE;

        if (selected) {
            selector.y = customTexts[textIndex].y + (customTexts[textIndex].height - selector.height) / 2;
        }

        textIndex++;
    }
}