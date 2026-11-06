import funkin.backend.system.Controls;
import funkin.options.PlayerSettings;

class Room {
	public var camOffice:FlxCamera;

	var room:String = FlxG.save.data.rooms;

	public var controls(get, never):Controls;

	inline function get_controls():Controls
		return PlayerSettings.solo.controls;

	public var doorr:FlxSprite;
	public var doorl:FlxSprite;
	public var left:FlxSprite;
	public var middle:FlxSprite;
	public var middle2:FlxSprite;
	public var back:FlxSprite;
	public var right:FlxSprite;
	public var top:FlxSprite;
	public var bottom:FlxSprite;

	public var leftMon:FlxSprite;
	public var rightMon:FlxSprite;
	public var backMon:FlxSprite;

	public var sprites:FlxGroup;
	public var gameon:Bool = false;
	public var lookingBehind:Bool = false;

	var offsetTween:FlxTween;

	public var shaderLeft:FlxShader = new CustomShader("cubemap");
	public var shaderMid:FlxShader = new CustomShader("cubemap");
	public var shaderBack:FlxShader = new CustomShader("cubemap");
	public var shaderRight:FlxShader = new CustomShader("cubemap");
	public var shaderTop:FlxShader = new CustomShader("cubemap");
	public var shaderBottom:FlxShader = new CustomShader("cubemap");
	public var tvstatic = new CustomShader('static');

	public var cubeShaders = [shaderMid, shaderLeft, shaderBack, shaderRight, shaderTop, shaderBottom];

	var currentOffsetX:Float = 0;
	var targetOffsetX:Float = 0;
	var currentOffsetY:Float = 0;
	var targetOffsetY:Float = 0;

	var offsetExtra:Float = 0;

	var maxOffset:Float = 1.35;
	var maxOffsetY:Float = 0.65;
	var smooth:Float = 0.05;
	var time:Float = 0;

	var doorrClosed:Int;
	var doorrOpen:Int;

	var doorlClosed:Int;
	var doorlOpen:Int;
	var rightDoorTimer:Float = 0;
	var leftDoorTimer:Float = 0;

	public function new(?camera:FlxCamera) {
		camOffice = camera != null ? camera : FlxG.camera;
		sprites = new FlxGroup();
		createSprites();
	}

	function createSprites() {
		FlxG.mouse.visible = true;

		doorl = new FlxSprite().loadGraphic(Paths.image("rooms/" + room + "/door"));
		doorr = new FlxSprite().loadGraphic(Paths.image("rooms/" + room + "/door"));

		left = new FlxSprite().loadGraphic(Paths.image("rooms/" + room + "/left"));
		middle = new FlxSprite().loadGraphic(Paths.image('game/static2'));
		middle2 = new FlxSprite().loadGraphic(Paths.image("rooms/" + room + "/front"));
		back = new FlxSprite().loadGraphic(Paths.image("rooms/" + room + "/back"));
		right = new FlxSprite().loadGraphic(Paths.image("rooms/" + room + "/right"));
		
		leftMon = new FlxSprite().loadGraphic(Paths.image("game/leftMonnormal"));
		rightMon = new FlxSprite().loadGraphic(Paths.image("game/rightMonnormal"));
		backMon = new FlxSprite().loadGraphic(Paths.image("game/backMonnormal"));
		// add a way to customize this later per room option
		top = new FlxSprite().makeGraphic(512, 512, FlxColor.BLACK);
		if (room == 'frick') {
			bottom = new FlxSprite().makeGraphic(512, 512, 0xFF353535);
		} else {
			bottom = new FlxSprite().makeGraphic(512, 512, 0xFF87472b);
		}

		var doorcube = [doorr, doorl, leftMon, rightMon, backMon];
		var cube = [middle, left, back, right, top, bottom, middle2,];

		for (spr in doorcube) {
			spr.scale.set(6, 6);
			spr.cameras = [camOffice];
			spr.setPosition(0, 100);
			spr.screenCenter();
		}
		backMon.shader = shaderBack;
		sprites.add(backMon);

		for (spr in cube) {
			spr.scale.set(6, 6);
			spr.cameras = [camOffice];
			spr.setPosition(0, 100);
			spr.screenCenter();
			sprites.add(spr);
		}

		// for (spr in cube)
		// 	spr.x = middle.x;

		for (shader in cubeShaders)
			shader.fov = 0.5;

		shaderLeft.side = 1;
		shaderMid.side = 0;
		shaderBack.side = 2;
		shaderRight.side = 3;
		shaderTop.side = 4;
		shaderBottom.side = 5;

		for (i in 0...6) {
			cube[i].shader = cubeShaders[i];
		}
		if (FlxG.save.data.shaders) {
			middle.shader = tvstatic;
		}
		//at some point i said fuck it and just ditched for loops thats funny as fuck

		rightMon.shader = shaderRight;
		sprites.add(rightMon);
		leftMon.shader = shaderLeft;
		
		sprites.add(leftMon);

		middle2.shader = shaderMid;
		sprites.add(middle2);
		doorr.shader = shaderRight;
		doorrClosed = doorr.x;
		doorr.x += 1200;
		doorrOpen = doorr.x;
		sprites.add(doorr);
		doorl.shader = shaderLeft;
		doorlClosed = doorl.x;
		doorl.x -= 1200;
		doorlOpen = doorl.x;
		sprites.add(doorl);
	}

	public function update(elapsed:Float) {
		time += elapsed * 10;
		tvstatic.iTime = time;

		var mousePos = FlxG.mouse.getScreenPosition(camOffice);

		if (controls.getJustPressed("cabin_turn") && !gameon && offsetTween == null) {
			lookingBehind = !lookingBehind;
			var target:Float;

			if (currentOffsetX > 0) {
				target = offsetExtra + 3.14;
			} else {
				target = offsetExtra - 3.14;
			}
			offsetTween = FlxTween.num(offsetExtra, target, 0.5, {
				ease: FlxEase.quartOut,
				onComplete: function(tween:FlxTween) {
					offsetTween = null;
				}
			}, function(value:Float) {
				offsetExtra = value;
			});
			for (shader in [shaderLeft, shaderMid, shaderBack, shaderRight, shaderTop, shaderBottom]) {
				FlxTween.tween(shader, {fov: lookingBehind ? 1.25 : 0.5}, 0.75, {
					ease: lookingBehind ? FlxEase.cubeInOut : FlxEase.quartOut
				});
			}
			if (lookingBehind) {
				maxOffset = maxOffset / 4;
				maxOffsetY = maxOffsetY / 4;
			} else {
				maxOffset = maxOffset * 4;
				maxOffsetY = maxOffsetY * 4;
			}
		}

		targetOffsetX = gameon ? 0 : ((mousePos.x / FlxG.width - 0.5) / 1.5) * maxOffset;
		targetOffsetY = gameon ? 0 : ((mousePos.y / FlxG.height - 0.5) / 2) * maxOffsetY;

		currentOffsetX = FlxMath.bound(currentOffsetX + (targetOffsetX - currentOffsetX) * smooth, -maxOffset, maxOffset);
		currentOffsetY = FlxMath.bound(currentOffsetY + (targetOffsetY - currentOffsetY) * smooth, -maxOffsetY, maxOffsetY);

		for (shader in cubeShaders) {
			shader.data.yaw.value = [currentOffsetX + offsetExtra];
			shader.data.pitch.value = [currentOffsetY];
		}
	}

	public function updateDoors(doorR:Bool, doorL:Bool) {
		doorr.x = CoolUtil.fpsLerp(doorr.x, doorR ? doorrClosed : doorrOpen, 0.142);
		doorl.x = CoolUtil.fpsLerp(doorl.x, doorL ? doorlClosed : doorlOpen, 0.142);

		if (doorR) {
			rightDoorTimer = 0;
			doorr.visible = true;
		} else {
			rightDoorTimer += FlxG.elapsed;

			if (rightDoorTimer >= 0.50)
				doorr.visible = false;
		}

		if (doorL) {
			leftDoorTimer = 0;
			doorl.visible = true;
		} else {
			leftDoorTimer += FlxG.elapsed;

			if (leftDoorTimer >= 0.50)
				doorl.visible = false;
		}
	}
}
