import FunkinTypeText;

public var typing:FunkinTypeText = new FunkinTypeText(0, 0, FlxG.width, 8);
var camera:FlxCamera;
var blend:FlxSprite;
var transitioning:Bool = false;

typing.onComplete.add(() -> {
	endDialogue();
});
typing.onProgress.add(() -> {
	typing.screenCenter();
});
function create() {
	camera = new FlxCamera();
	camera.bgColor = FlxColor.BLACK;
	FlxG.cameras.add(camera, true);

	blend = new FlxSprite();
	blend.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
	blend.cameras = [camera];
	add(blend);

	if (data) {
		startDialogue("ending");
	} else {
		if (!FlxG.save.data.sawOpening) {
			startDialogue("title");
			FlxG.save.data.sawOpening = true;
			FlxG.save.flush();
		}
		else if (FlxG.save.data.sawOpening && FlxG.save.data.beatlevel5) {
			startDialogue("titleAfter");
		}
		else if (FlxG.save.data.sawOpening) {
			startDialogue("titleRepeat");
		}
	}
}

function startDialogue(json:String) {
	JamUtils.startDialogue(typing, "json/" + json);
	JamUtils.setupText(typing, 48, "center", "Outline.ttf");

	typing.cameras = [camera];
	typing.alpha = 0;
	typing.sounds = [FlxG.sound.load(Paths.sound("talkSounds/talk"))];

	add(typing);

	FlxTween.tween(typing, {alpha: 1}, 1.5, {
		ease: FlxEase.cubeOut
	});
}

function update(elapsed:Float) {
	if (transitioning)
		return;

	if (controls.ACCEPT) {
		if (typing.isTyping)
			typing.skip();
		else
			typing.continueDialogue();
	}
}

function endDialogue() {
	if (transitioning)
		return;
	CoolUtil.playMenuSFX(1, 1);

	transitioning = true;

	FlxTween.tween(typing, {alpha: 0}, 1, {
		ease: FlxEase.cubeOut
	});

	FlxTween.tween(blend, {alpha: 0}, 1.5, {
		ease: FlxEase.cubeOut,
		onComplete: function(_) {
			FlxG.switchState(new MainMenuState());
		}
	});
}
