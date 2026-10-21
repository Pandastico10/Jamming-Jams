class Room {
	public var camOffice:FlxCamera;

	var room:String = FlxG.save.data.rooms;

	public var left:FlxSprite;
	public var middle:FlxSprite;
	public var middle2:FlxSprite;
	public var back:FlxSprite;
	public var right:FlxSprite;
	public var top:FlxSprite;
	public var bottom:FlxSprite;

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

	public function new(?camera:FlxCamera) {
		camOffice = camera != null ? camera : FlxG.camera;
		sprites = new FlxGroup();
		createSprites();
	}

	function createSprites() {
		FlxG.mouse.visible = true;

		left = new FlxSprite().loadGraphic(Paths.image("rooms/" + room + "/left"));
		middle = new FlxSprite().loadGraphic(Paths.image('game/static2'));
		middle2 = new FlxSprite().loadGraphic(Paths.image("rooms/" + room + "/front"));
		back = new FlxSprite().loadGraphic(Paths.image("rooms/" + room + "/back"));
		right = new FlxSprite().loadGraphic(Paths.image("rooms/" + room + "/right"));
		// add a way to customize this later per room option
		top = new FlxSprite().makeGraphic(512, 512, FlxColor.BLACK);
		bottom = new FlxSprite().makeGraphic(512, 512, 0xFF87472b);

		var cube = [middle, left, back, right, top, bottom, middle2];

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
		middle2.shader = shaderMid;
		sprites.add(middle2);
	}

	public function update(elapsed:Float) {
		time += elapsed * 10;
		tvstatic.iTime = time;

		var mousePos = FlxG.mouse.getScreenPosition(camOffice);

		if (FlxG.keys.justPressed.S && !gameon && offsetTween == null) {
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
}
