class Room {
	public var camOffice:FlxCamera;

	public var left:FlxSprite;
	public var middle:FlxSprite;
	public var middle2:FlxSprite;
	public var back:FlxSprite;
	public var right:FlxSprite;
	public var top:FlxSprite;
	public var bottom:FlxSprite;

	public var sprites:FlxGroup;
	public var gameon:Bool = false;

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

	var maxOffset:Float = 1.575;
	var maxOffsetY:Float = 1.0;
	var smooth:Float = 0.04;
	var time:Float = 0;

	public function new(?camera:FlxCamera) {
		camOffice = camera != null ? camera : FlxG.camera;
		sprites = new FlxGroup();
		createSprites();
	}

	function createSprites() {
		FlxG.mouse.visible = true;

		left = new FlxSprite().loadGraphic(Paths.image("stages/office/officeleft"));
		middle = new FlxSprite().loadGraphic(Paths.image('game/static2'));
		middle2 = new FlxSprite().loadGraphic(Paths.image('stages/office/officefront'));
		back = new FlxSprite().loadGraphic(Paths.image("stages/office/officeback"));
		right = new FlxSprite().loadGraphic(Paths.image("stages/office/officeright"));
		top = new FlxSprite().makeGraphic(512, 512, FlxColor.BLACK);
		bottom = new FlxSprite().makeGraphic(512, 512, 0xFF353535);

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

		for (shader in cubeShaders) {
			shader.data.yaw.value = [currentOffsetX];
			shader.data.pitch.value = [currentOffsetY];
		}
	}
}
