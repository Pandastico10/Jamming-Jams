import flixel.util.FlxSpriteUtil;
import funkin.backend.system.Controls;
import funkin.options.PlayerSettings;

class Player extends FlxSprite {
	public var controls(get, never):Controls;

	inline function get_controls():Controls
		return PlayerSettings.solo.controls;

	public var jumpStrength:Int = 500;
	public var poundStrength:Int = 700;
	public var maxSpeed:Int = 300;
	public var gravity:Int = 1400;
	public var maxJumpAmm:Int = 1;
	public var jumpAmm:Int = 1;
	public var playable:Bool = false;
	public var ogX:Float;
	public var ogY:Float;
	public var jumpTimer:Float = 0;
	public var maxJumpTime:Float = 0.25;

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
			jumpTimer = 0;
		}
	}

	override public function update(elapsed:Float) {
		if (!playable) {
			super.update(elapsed);
			return;
		}

		if (controls.getPressed("player_up")) {
			jumpTimer += elapsed;

			if (jumpTimer < 0.025)
				velocity.y = -jumpStrength;
		}

		if (controls.getJustPressed("player_up") && isTouching(0x1000)) {
			jumpSfx.play();
		}

		if (controls.getJustReleased("player_up") && jumpTimer < 0.25) {
			velocity.y += 200;
			jumpTimer = 0.25;
		}

		if (controls.getJustPressed("player_up") && !isTouching(0x1000) && jumpAmm > 0) {
			jumpSfx.pitch += 0.1;
			jumpSfx.play();

			velocity.y = -jumpStrength;
			jumpAmm--;
			jumpTimer = 0;

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
			jumpTimer = 0;
		}

		if (controls.getJustPressed("player_down") && !isTouching(0x1000)) {
			velocity.y = poundStrength;
			FlxG.sound.play(Paths.sound("sfxPound"));
		}

		acceleration.x = 0;

		if (controls.getPressed("player_left")) {
			flipX = true;
			acceleration.x -= drag.x;
		}

		if (controls.getPressed("player_right")) {
			flipX = false;
			acceleration.x += drag.x;
		}

		super.update(elapsed);
	}
}
