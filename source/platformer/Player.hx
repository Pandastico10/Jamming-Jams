import flixel.util.FlxSpriteUtil;

class Player extends FlxSprite {
	public var jumpStrength:Int = 500;
	public var poundStrength:Int = 500;
	public var maxSpeed:Int = 300;
	public var gravity:Int = 1400;
	public var maxJumpAmm:Int = 1;
	public var jumpAmm:Int = 1;
	public var playable:Bool = false;
	public var ogX:Float;
	public var ogY:Float;

	public var jumpSfx:FlxSound = new FlxSound();

	public function new(x:Float, y:Float) {
		super(x, y);

		loadGraphic(Paths.image("characters/char"));
		setGraphicSize(25, 25);
		updateHitbox();
		ogX = x;
		ogY = y;

		jumpAmm = maxJumpAmm;
		jumpSfx.loadEmbedded(Paths.sound("sfxJump1"));
	}

	public function test() {
		x = ogX;
		y = ogY;
		playable = !playable;
		if (playable) {
			acceleration.y = gravity;
			maxVelocity.y = maxSpeed * 2;
			maxVelocity.x = maxSpeed;
			drag.x = maxVelocity.x * 4;
		} else {
			acceleration.y = 0;
			acceleration.x = 0;
			maxVelocity.y = 0;
			maxVelocity.x = 0;
			velocity.x = 0;
			velocity.y = 0;
		}
	}

	override public function update(elapsed:Float) {
		if (playable) {
			if ((FlxG.keys.justPressed.UP || FlxG.keys.justPressed.W) && isTouching(0x1000)) {
				velocity.y = -jumpStrength;
				jumpSfx.play();
			}

			if ((FlxG.keys.justPressed.UP || FlxG.keys.justPressed.W) && !isTouching(0x1000) && jumpAmm > 0) {
				jumpSfx.pitch += 0.1;
				jumpSfx.play();

				velocity.y = -jumpStrength;
				jumpAmm--;

				FlxTween.cancelTweensOf(this);
				angle = 0;

				FlxTween.tween(this, {angle: -360}, 0.5, {
					ease: FlxEase.cubeOut
				});
			}

			if (isTouching(0x1000)) {
				jumpAmm = maxJumpAmm;
				angle = 0;
				jumpSfx.pitch = 1;
			}

			if (FlxG.keys.justPressed.DOWN || FlxG.keys.justPressed.S && !isTouching(0x1000)) {
				velocity.y = poundStrength;
				FlxG.sound.play(Paths.sound("sfxPound"));
			}

			acceleration.x = 0;

			if (FlxG.keys.pressed.LEFT || FlxG.keys.pressed.A) {
				flipX = true;
				acceleration.x -= drag.x;
			}

			if (FlxG.keys.pressed.RIGHT || FlxG.keys.pressed.D) {
				flipX = false;
				acceleration.x += drag.x;
			}
		}
		super.update(elapsed);
	}
}
