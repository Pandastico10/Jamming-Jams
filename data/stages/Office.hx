import flixel.tweens.FlxTween;
import openfl.display.BlendMode;
import data.scripts.IntCameras;
import flixel.util.FlxStringUtil;

var cameraSetup:IntCameras;
var time:FlxText;
var timer:Int = 0;
var top:FlxSprite;
var left:FlxSprite;
var leftout:FlxSprite;
var doorleft:FlxSprite;
var middle:FlxSprite;
var middle2:FlxSprite;
var middle3:FlxSprite;
var middleOff:FlxSprite;
var middleOn:FlxSprite;
var back:FlxSprite;
var right:FlxSprite;
var rightout:FlxSprite;
var doorright:FlxSprite;
var mask:FlxSprite;
var maskOn:Bool = false;
var maskYUp:Float;
var maskYDown:Float;
var maskTween:FlxTween;
var shaderLeft:FlxShader;
var shaderMid:FlxShader;
var shaderBack:FlxShader;
var shaderRight:FlxShader;
var shaderTop:FlxShader;
var shaderBottom:FlxShader;
var camOffice:FlxCamera;
var currentOffsetX:Float = 0;
var targetOffsetX:Float = 0;
var currentOffsetY:Float = 0;
var targetOffsetY:Float = 0;

// var maxOffset:Float = 1.575;
// var maxOffsetY:Float = 1.0;

var maxOffset:Float = 3.15;
var maxOffsetY:Float = 1.5;
var smooth:Float = 0.04;
var doorSprites:Array<FlxSprite>;
var doorOpenY:Array<Float>;
var doorClosedY:Array<Float>;
var doorTweens:Array<FlxTween>;
var doors:Array<Bool>;
var flash0:FlxSprite;
var flash1:FlxSprite;
var flashOn:Bool = false;
var power:Int = 20;
var maxPower:Int = 20;
var powerSquares:Array<FlxSprite> = [];
var drainTimer:Float = 0;
var drainSpeed:Float = 5; // higher = slower
var jumpActive:Bool = false;
var jumpBody:FlxSprite;
var jumpHead:FlxSprite;
var jumpFrame:Float = 0;
var jumpSide:Int = 0; // -1 left, 0 center, 1 right
var cameraX:Float = 0;
var cameraY:Float = 0;
var cameraZ:Float = 0;

function create() {
	introLength = 0;
	camOffice = new FlxCamera();
	camOffice.bgColor = 0xFF353535;
	// camOffice.bgColor = 0;
	camOffice.zoom = 0.35;

	FlxG.cameras.add(camOffice, false);
	FlxG.cameras.add(camHUD, false);

	flash0 = new FlxSprite().loadGraphic(Paths.image('stages/office/flash0'));
	flash0.cameras = [camOffice];
	flash0.scrollFactor.set();
	flash0.alpha = 0.65;
	flash0.blend = BlendMode.MULTIPLY;
	flash0.scale.set(6, 6);

	flash1 = new FlxSprite().loadGraphic(Paths.image('stages/office/flash1'));
	flash1.cameras = [camOffice];
	flash1.scrollFactor.set();
	flash1.blend = BlendMode.MULTIPLY;
	flash1.visible = true;
	flash1.alpha = 0.65;
	flash1.scale.set(6, 6);

	UI = new FlxSprite().loadGraphic(Paths.image('stages/office/ui'));
	UI.scrollFactor.set(1, 1);
	UI.scale.set(2, 2);
	UI.cameras = [camHUD];

	mask = new FlxSprite().loadGraphic(Paths.image('stages/office/mask'));
	mask.scrollFactor.set(1, 1);
	mask.scale.set(5.8, 5.8);
	mask.cameras = [camOffice];

	var night = new FlxText(65, 640, FlxG.width, "Night 1");
	night.setFormat(Paths.font('Cam.otf'), 25, FlxColor.BLACK);
	night.cameras = [camHUD];

	time = new FlxText(65, 670, FlxG.width, "HIHIHIHI");
	time.setFormat(Paths.font('Cam.otf'), 25, FlxColor.BLACK);
	time.cameras = [camHUD];

	top = new FlxSprite().makeGraphic(192, 192, FlxColor.BLACK);

	left = new FlxSprite().loadGraphic(Paths.image('stages/office/officeleft'));
	leftout = new FlxSprite().loadGraphic(Paths.image('stages/office/officeleftout'));
	doorleft = new FlxSprite().loadGraphic(Paths.image('stages/office/doorleft'));

	middle = new FlxSprite().loadGraphic(Paths.image('stages/office/officefront'));
	middle2 = new FlxSprite().makeGraphic(512, 512, FlxColor.BLACK);
	middle3 = new FlxSprite().makeGraphic(512, 512, 0xFF353535);
	middleOff = new FlxSprite().loadGraphic(Paths.image('stages/office/officefrontoutoff'));
	middleOn = new FlxSprite().loadGraphic(Paths.image('stages/office/officefrontouton'));

	back = new FlxSprite().loadGraphic(Paths.image('stages/office/officeback'));

	right = new FlxSprite().loadGraphic(Paths.image('stages/office/officeright'));
	rightout = new FlxSprite().loadGraphic(Paths.image('stages/office/officerightout'));
	doorright = new FlxSprite().loadGraphic(Paths.image('stages/office/doorright'));

	var office = [
		  left,   leftout,  doorleft,
		middle, middleOff,  middleOn,
		 right,  rightout, doorright,
		  back,   middle2,   middle3
	];

	for (spr in office) {
		spr.scale.set(8, 8);
		spr.cameras = [camOffice];
		spr.setPosition(0, 100);
	}

	middle.screenCenter();
	middle2.screenCenter();
	middle3.screenCenter();
	UI.screenCenter();
	mask.screenCenter();

	for (spr in office)
		spr.x = middle.x;

	shaderLeft = new CustomShader("cubemap");
	shaderMid = new CustomShader("cubemap");
	shaderBack = new CustomShader("cubemap");
	shaderRight = new CustomShader("cubemap");
	shaderTop = new CustomShader("cubemap");
	shaderBottom = new CustomShader("cubemap");

	shaderLeft.data.side.value = [1];
	shaderMid.data.side.value = [0];
	shaderBack.data.side.value = [2];
	shaderRight.data.side.value = [3];
	shaderTop.data.side.value = [4];
	shaderBottom.data.side.value = [5];

	for (spr in [left, leftout, doorleft])
		spr.shader = shaderLeft;
	for (spr in [middle, middleOff, middleOn])
		spr.shader = shaderMid;
	for (spr in [right, rightout, doorright])
		spr.shader = shaderRight;
	back.shader = shaderBack;
	middle2.shader = shaderTop;
	middle3.shader = shaderBottom;

	remove(strumLines.members[2], false);

	add(leftout);
	add(rightout);
	add(doorleft);
	add(doorright);
	add(middleOff);
	add(middleOn);

	add(strumLines.members[2]);

	add(left);
	add(right);
	add(middle);
	add(back);
	add(middle2);
	add(middle3);
	add(flash0);
	add(flash1);
	add(mask);
	add(UI);
	add(night);
	add(time);

	doorleft.y -= 3000;
	doorright.y -= 3000;
	mask.y -= 2500;

	maskYUp = mask.y;
	maskYDown = mask.y + 2500;

	doors = [false, false];
	doorSprites = [doorleft, doorright];
	doorOpenY = [doorleft.y, doorright.y];
	doorClosedY = [doorleft.y + 3000, doorright.y + 3000];
	doorTweens = [null, null];

	cameraSetup = new IntCameras();

	for (i in 0...maxPower) {
		var sq = new FlxSprite(97, 19).makeGraphic(10, 14, FlxColor.BLACK);
		sq.cameras = [camHUD];
		sq.x = sq.x + i * 12;
		add(sq);
		powerSquares.push(sq);
	}
}

function postCreate() {
	healthBar.visible = healthBarBG.visible = scoreTxt.visible = missesTxt.visible = accuracyTxt.visible = false;
	iconP1.visible = false;
	iconP2.visible = false;

	for (e in strumLines.members[2]) {
		e.cameras = [camOffice];
		e.scrollFactor.set(1, 1);
		e.scale.set(1, 1);
		e.x += 300;
		e.y = middle.y - 1000;
	}
}

function onNoteCreation(event) {
	// event.note.shader = shaderMid;
}

function update(elapsed:Float) {
	cameraSetup.update();

	drainTimer += elapsed;

	if (drainTimer >= drainSpeed) {
		drainTimer = 0;

		if (power > 0) {
			power--;
			updatePowerDisplay();
		}
	}

	if (FlxG.keys.pressed.LEFT)
		cameraX -= 2 * elapsed;

	if (FlxG.keys.pressed.RIGHT)
		cameraX += 2 * elapsed;

	if (FlxG.keys.pressed.DOWN)
		cameraZ -= 2 * elapsed;

	if (FlxG.keys.pressed.UP)
		cameraZ += 2 * elapsed;

	cameraX = FlxMath.bound(cameraX, -0.9, 0.9);
	cameraY = FlxMath.bound(cameraY, -0.9, 0.9);
	cameraZ = FlxMath.bound(cameraZ, -0.9, 0.9);

	// shaderLeft.data.cameraX.value = [cameraX];
	// shaderLeft.data.cameraY.value = [cameraY];
	// shaderLeft.data.cameraZ.value = [cameraZ];

	var current:Float = Conductor.songPosition;
	var total:Float = FlxG.sound.music.length;

	var progress:Float = current / total;
	var totalMinutes:Float = progress * 6 * 60;
	var hour:Int = 12 + Std.int(totalMinutes / 60);
	var minutes:Int = Std.int(totalMinutes % 60);
	if (hour > 12)
		hour -= 12;

	time.text = hour + ":" + StringTools.lpad(Std.string(minutes), "0", 2) + " AM";

	if (FlxG.keys.justPressed.A) {
		toggleDoor(0);
		FlxG.sound.play(Paths.sound('sfxDoor'));
	}

	if (FlxG.keys.justPressed.D) {
		toggleDoor(1);
		FlxG.sound.play(Paths.sound('sfxDoor'));
	}

	if (FlxG.keys.justPressed.W && !cameraSetup.camOn) {
		maskOn = !maskOn;
		FlxG.sound.play(Paths.sound(maskOn ? 'sfxMaskOn' : 'sfxMaskOff'));

		if (maskTween != null)
			maskTween.cancel();

		var targetY = maskOn ? maskYDown : maskYUp;
		maskTween = FlxTween.tween(mask, {y: targetY}, 0.3, {ease: FlxEase.cubeInOut});
	}

	flashOn = FlxG.keys.pressed.Z;

	if (flashOn) {
		var mousePos = FlxG.mouse.getScreenPosition(camOffice);
		flash1.visible = true;
		flash0.visible = false;
		flash1.x = mousePos.x - 620;
		flash1.y = mousePos.y - 350;
	} else {
		flash1.visible = false;
		flash0.visible = true;
	}
	if (jumpActive) {
		jumpFrame += 1;

		var targetX = FlxG.width / 2 - 350;
		var targetY = FlxG.height / 2 - 400;

		jumpBody.x += (targetX - jumpBody.x) / 5;
		jumpBody.y += (targetY - jumpBody.y) / 5;

		jumpHead.x = jumpBody.x;
		jumpHead.y = jumpBody.y;

		jumpBody.scale.x += 0.01;
		jumpBody.scale.y += 0.01;

		jumpHead.scale.x += 0.02;
		jumpHead.scale.y += 0.02;

		var vibration = (jumpFrame / 5) + 1;
		var frameVal = 1 - (Math.floor(jumpFrame) % 3);

		var offset = ((frameVal * 2) / vibration) * 8;

		jumpBody.x += offset;
		jumpHead.angle = offset * 5;
	}

	if (FlxG.keys.justPressed.Z)
		FlxG.sound.play(Paths.sound('sfxFlashlightOn'));
	if (FlxG.keys.justReleased.Z)
		FlxG.sound.play(Paths.sound('sfxFlashlightOff'));
}

function postUpdate(elapsed:Float) {
	var mousePos = FlxG.mouse.getScreenPosition(camHUD);
	var centeredX:Float = (mousePos.x / FlxG.width - 0.5) * 2;
	var centeredY:Float = (mousePos.y / FlxG.height - 0.5) * 2;

	targetOffsetX = centeredX * maxOffset;
	targetOffsetY = centeredY * maxOffsetY;
	currentOffsetX += (targetOffsetX - currentOffsetX) * smooth;
	currentOffsetX = FlxMath.bound(currentOffsetX, -maxOffset, maxOffset);

	currentOffsetY += (targetOffsetY - currentOffsetY) * smooth;
	currentOffsetY = FlxMath.bound(currentOffsetY, -maxOffsetY, maxOffsetY);

	var yaw:Float = currentOffsetX;
	var yval:Float = currentOffsetY;

	shaderLeft.data.yaw.value = [yaw];
	shaderMid.data.yaw.value = [yaw];
	shaderRight.data.yaw.value = [yaw];
	shaderBack.data.yaw.value = [yaw];
	shaderTop.data.yaw.value = [yaw];

	shaderLeft.data.pitch.value = [yval];
	shaderMid.data.pitch.value = [yval];
	shaderRight.data.pitch.value = [yval];
	shaderBack.data.pitch.value = [yval];
	shaderTop.data.pitch.value = [yval];
}

function toggleDoor(i:Int) {
	doors[i] = !doors[i];

	if (doorTweens[i] != null)
		doorTweens[i].cancel();

	var targetY = doors[i] ? doorClosedY[i] : doorOpenY[i];

	doorTweens[i] = FlxTween.tween(doorSprites[i], {y: targetY}, 0.2, {
		ease: FlxEase.quadOut
	});
}

function updatePowerDisplay() {
	for (i in 0...maxPower) {
		powerSquares[i].visible = i < power;
	}
}