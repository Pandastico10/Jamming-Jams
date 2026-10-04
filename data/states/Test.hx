import funkin.editors.ui.UISliceSprite;
import openfl.geom.Matrix;

// game vars
var sprite:FlxSprite;
var box:FlxSprite;
var drag:Float;
var jumped:Bool = false;
var bound1 = new FlxSprite();
var bound2 = new FlxSprite();
var blend = new FlxSprite();
var blend1 = new FlxSprite();
var drone = new FlxSound();
var jumpSfx:FlxSound = new FlxSound();

// game shaders
var distortion = new CustomShader('chromaticWarp');
var scanline = new CustomShader('scanline');

// game funny numbers yayy
var jumpStrenght:Int = 500;
var poundStrenght:Int = 500;
var maxSpeed:Int = 300;
var gravity:Int = 1400;
var maxJumpAmm:Int = 3;
var jumpAmm:Int = maxJumpAmm;

// camera vars
var camOffice:FlxCamera;
var left:FlxSprite;
var middle:FlxSprite;
var back:FlxSprite;
var right:FlxSprite;
var top:FlxSprite;
var bottom:FlxSprite;
var shaderLeft:FlxShader = new CustomShader("cubemap");
var shaderMid:FlxShader = new CustomShader("cubemap");
var shaderBack:FlxShader = new CustomShader("cubemap");
var shaderRight:FlxShader = new CustomShader("cubemap");
var shaderTop:FlxShader = new CustomShader("cubemap");
var shaderBottom:FlxShader = new CustomShader("cubemap");

// camera funni-er numbers yipee
var currentOffsetX:Float = 0;
var targetOffsetX:Float = 0;
var currentOffsetY:Float = 0;
var targetOffsetY:Float = 0;
var maxOffset:Float = 1.575;
var maxOffsetY:Float = 1.0;
var smooth:Float = 0.04;
var gameon:Bool = true;
var debugLayer = new FlxGroup();

function create() {
	// cameras
	camOffice = new FlxCamera();
	camOffice.bgColor = 0xFF353535;
	camOffice.zoom = 0.35;
	FlxG.cameras.add(camOffice, false);
	FlxG.mouse.visible = true;
	left = new FlxSprite().loadGraphic(Paths.image("stages/office/officeleft"));
	middle = new FlxSprite().loadGraphic(Paths.image("stages/office/officefront"));
	back = new FlxSprite().loadGraphic(Paths.image("stages/office/officeback"));
	right = new FlxSprite().loadGraphic(Paths.image("stages/office/officeright"));
	top = new FlxSprite().makeGraphic(512, 512, FlxColor.BLACK);
	bottom = new FlxSprite().makeGraphic(512, 512, 0xFF353535);
	var cube = [left, middle, back, right, top, bottom];
	var cubeShaders = [shaderLeft, shaderMid, shaderBack, shaderRight, shaderTop, shaderBottom];

	//position all sprites into a cube
	for (spr in cube) {
		spr.scale.set(6, 6);
		spr.cameras = [camOffice];
		spr.setPosition(0, 100);
		spr.screenCenter();
	}
	for (spr in cube) spr.x = middle.x;

	//setup Shaders
	for (i in cubeShaders) i.fov = 1;

	shaderLeft.side = 1;
	shaderMid.side = 0;
	shaderBack.side = 2;
	shaderRight.side = 3;
	shaderTop.side = 4;
	shaderBottom.side = 5;

	//add cube and apply shaders
	for (i in 0...6){
		cube[i].shader = cubeShaders[i];
		add(cube[i]);
	}
	// game
	CoolUtil.playMusic(Paths.music("field"), true, 0.8, true, 136);
	camGame = new FlxCamera();
	FlxG.cameras.add(camGame, true);
	camGame.bgColor = 0;

	// is this just straight up not muting whuh??
	jumpSfx.loadEmbedded(Paths.sound('sfxJump1'));
	drone.loadEmbedded(Paths.music("drone"), true);
	drone.group = FlxG.sound.defaultMusicGroup;
	FlxG.sound.defaultMusicGroup.add(drone);
	drone.volume = 0;
	drone.play();

	distortion.distortion = 0.25;

	blend1.makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
	add(blend1);

	blend.makeGraphic(FlxG.width, FlxG.height, 0xFF1F1F1F);
	blend.alpha = 0;
	add(blend);

	sprite = new FlxSprite().loadGraphic(Paths.image("characters/char"));
	sprite.setGraphicSize(25, 25);
	sprite.updateHitbox();
	sprite.x = FlxG.width / 2 - sprite.width / 2;
	sprite.acceleration.y = gravity;
	sprite.maxVelocity.y = maxSpeed * 2;
	sprite.maxVelocity.x = maxSpeed;
	add(sprite);
	sprite.drag.x = sprite.maxVelocity.x * 4;

	box = new FlxSprite();
	box.makeGraphic(32, 32, 0xFFFFFFFF);
	box.screenCenter();
	box.x = FlxG.width / 2 - box.width / 2;
	box.y = FlxG.height * 0.75 - box.height / 2;
	box.immovable = true;
	add(box);

	bound1.makeGraphic(FlxG.width, 100, 0xFFFFFFFF);
	bound1.screenCenter();
	bound1.y = FlxG.height - 64;
	bound1.immovable = true;
	add(bound1);

	bound2.makeGraphic(FlxG.width, 100, 0xFFFFFFFF);
	bound2.screenCenter();
	bound2.y = !FlxG.height - 36;
	bound2.immovable = true;
	add(bound2);

	for (i in [sprite, box, bound1, bound2, blend])
		i.cameras = [camGame];
	// camGame.addShader(distortion);
	// camGame.addShader(scanline);

	var gridSize:Int = 32;
	var cols:Int = Std.int(camGame.width / gridSize);
	var rows:Int = Std.int(camGame.height / gridSize);

	for (row in 0...rows + 1) {
		var lineH = new FlxSprite(0, row * gridSize);
		lineH.makeGraphic(cols * gridSize, 2, FlxColor.YELLOW);
		lineH.alpha = 0.5;
		debugLayer.add(lineH);
	}
	for (col in 0...cols + 1) {
		var lineV = new FlxSprite(col * gridSize, 0);
		lineV.makeGraphic(2, rows * gridSize, FlxColor.YELLOW);
		lineV.alpha = 0.5;
		debugLayer.add(lineV);
	}
	add(debugLayer);
}

function update(elapsed:Float) {
	FlxG.collide(box, sprite);
	FlxG.collide(bound1, sprite);
	FlxG.collide(bound2, sprite);

	var mouse = FlxG.mouse.getScreenPosition(camOffice);

	if (gameon) {
		// jump if touching a floor, and jump is pressed
		if (FlxG.keys.justPressed.UP && sprite.isTouching(0x1000)) {
			sprite.velocity.y = -jumpStrenght;
			jumpSfx.play();
		}

		if (FlxG.keys.justPressed.UP && !sprite.isTouching(0x1000) && jumpAmm > 0) {
			jumpSfx.pitch += 0.1;
			jumpSfx.play();
			sprite.velocity.y = -jumpStrenght;
			jumpAmm--;
			FlxTween.cancelTweensOf(sprite);
			sprite.angle = 0;
			FlxTween.tween(sprite, {angle: -360}, 0.5, {ease: FlxEase.cubeOut});
		}
		if (sprite.isTouching(0x1000)) {
			jumpAmm = maxJumpAmm;
			sprite.angle = 0;
			jumpSfx.pitch = 1;
		}
		if (FlxG.keys.pressed.DOWN && !sprite.isTouching(0x1000)) {
			sprite.velocity.y = poundStrenght;
		}
		// set acc to 0 before movement
		sprite.acceleration.x = 0;
		if (FlxG.keys.pressed.LEFT) {
			sprite.flipX = true;
			sprite.acceleration.x -= sprite.drag.x;
		}
		if (FlxG.keys.pressed.RIGHT) {
			sprite.flipX = false;
			sprite.acceleration.x += sprite.drag.x;
		}
	} else {
		sprite.velocity.x = 0;
		sprite.velocity.y = 0;
	}
	if (FlxG.keys.justPressed.G) {
		if (gameon) {
			FlxG.sound.music.pause();
			drone.fadeIn(2, 0, 2);
		} else {
			FlxG.sound.music.resume();
			drone.pause();
		}
		gameon = !gameon;
		FlxTween.cancelTweensOf(blend);

		var easing = gameon ? FlxEase.cubeIn : FlxEase.cubeOut;
		for (i in [shaderLeft, shaderMid, shaderBack, shaderRight, shaderTop, shaderBottom])
			FlxTween.tween(i, {fov: gameon ? 1.5 : 0.5}, 0.5, {ease: easing});
		FlxTween.tween(camGame, {alpha: gameon ? 1 : 0}, 0.5, {ease: easing});
		var matrix = new Matrix();

		matrix.scale(middle.pixels.width / camGame.canvas.width, middle.pixels.height / camGame.canvas.height);
		middle.pixels.draw(camGame.canvas, matrix);
	}
	if (controls.BACK) FlxG.switchState(new MainMenuState());
	// if (FlxG.mouse.justPressed) trace(FlxG.mouse.getWorldPosition(camOffice));
	if (FlxG.mouse.justPressed && !gameon && mouse.x > 54 && mouse.x < 232 && mouse.y > 240 && mouse.y < 560)
		trace("closed left");
	if (FlxG.mouse.justPressed && !gameon && mouse.x > 785 && mouse.x < 970 && mouse.y > 240 && mouse.y < 560)
		trace("closed right");
}

function measureHit(curMeasure:Int) {
	FlxTween.cancelTweensOf(blend);
	blend.alpha = 1;
	FlxTween.tween(blend, {alpha: 0}, 1, {ease: FlxEase.cubeOut});
}

function postUpdate(elapsed:Float) {
	var mousePos = FlxG.mouse.getScreenPosition(camOffice);
	var centeredX:Float = (mousePos.x / FlxG.width - 0.5) / 1.5;
	var centeredY:Float = (mousePos.y / FlxG.height - 0.5) / 2;
	if (gameon) {
		centeredX = 0;
		centeredY = 0;
	}
	targetOffsetX = centeredX * maxOffset;
	targetOffsetY = centeredY * maxOffsetY;
	currentOffsetX += (targetOffsetX - currentOffsetX) * smooth;
	currentOffsetY += (targetOffsetY - currentOffsetY) * smooth;
	currentOffsetX = FlxMath.bound(currentOffsetX, -maxOffset, maxOffset);
	currentOffsetY = FlxMath.bound(currentOffsetY, -maxOffsetY, maxOffsetY);
	var yaw:Float = currentOffsetX;
	var pitch:Float = currentOffsetY;
	shaderLeft.data.yaw.value = [yaw];
	shaderMid.data.yaw.value = [yaw];
	shaderBack.data.yaw.value = [yaw];
	shaderRight.data.yaw.value = [yaw];
	shaderTop.data.yaw.value = [yaw];
	shaderBottom.data.yaw.value = [yaw];
	shaderLeft.data.pitch.value = [pitch];
	shaderMid.data.pitch.value = [pitch];
	shaderBack.data.pitch.value = [pitch];
	shaderRight.data.pitch.value = [pitch];
	shaderTop.data.pitch.value = [pitch];
	shaderBottom.data.pitch.value = [pitch];
}
