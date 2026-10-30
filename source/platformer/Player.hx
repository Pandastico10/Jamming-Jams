import funkin.backend.system.Controls;
import funkin.options.PlayerSettings;
import flixel.addons.effects.FlxTrail;
import flixel.effects.FlxFlicker;

class Player extends FlxSprite {
	public var controls(get, never):Controls;

	inline function get_controls():Controls
		return PlayerSettings.solo.controls;

	public var jumpStrength:Int = 500;
	public var poundStrength:Int = 700;
	public var maxSpeed:Int = 300;
	public var playable:Bool = false;
	public var ogX:Float;
	public var ogY:Float;
	public var jumpTimer:Float = 0;
	public var maxJumpTime:Float = 0.25;
	public var ability:String = FlxG.save.data.playerAbility;
	public var trail:FlxTrail;
	public var abilityIndicator:FlxSprite;

	public var jumpSfx:FlxSound = new FlxSound();
	public var boostSfx:FlxSound = new FlxSound();
	public var stopSfx:FlxSound = new FlxSound();
	public var switchSfx:FlxSound = new FlxSound();
	public var immunitySfx:FlxSound = new FlxSound();

	public var maxJumpAmm:Int = 1;
	public var jumpAmm:Int = 1;

	public var immunityTimer:Float = 0;
	public var immunityDuration:Float = 1.5;
	public var immunityCooldown:Float = 15;
	public var immune:Bool = false;
	public var gotHit:Bool = false;

	var dashSpeed:Float = 600;
	var dashDuration:Float = 0.35;
	var dashTimer:Float = 0;
	var dashing:Bool = false;

	public var dashAvailable:Bool = true;

	var timeScale:Float = 0.50;

	public var slowdown:Bool = false;
	public var maxTimeCharge:Float = 1.5;
	public var timeTimer:Float = 1.5;
	public var timeRechargeDuration:Float = 5;

	public var gravityFlipped:Bool = false;
	public var normalGravity:Float = 1400;
	public var gravity:Int = 1400;
	public var canFlip:Bool = false;

	public function new(x:Float, y:Float, jumps:Int) {
		super(x, y);

		loadGraphic(Paths.image("characters/char"));
		setGraphicSize(25, 25);
		updateHitbox();

		abilityIndicator = new FlxSprite();
		abilityIndicator.makeGraphic(6, 6, FlxColor.WHITE);
		abilityIndicator.visible = false;

		ogX = x;
		ogY = y;

		maxJumpAmm = jumps;
		jumpAmm = maxJumpAmm;

		baseMaxSpeed = maxSpeed;

		jumpSfx = FlxG.sound.load(Paths.sound("sfxJump1"), 1, false);
		boostSfx = FlxG.sound.load(Paths.sound("boost"), 1, false);
		switchSfx = FlxG.sound.load(Paths.sound("switch"), 1, false);
		stopSfx = FlxG.sound.load(Paths.sound("stop"), 1, false);
		immunitySfx = FlxG.sound.load(Paths.sound("immunity"), 1, false);

		if (!FlxG.save.data.performance)
			trail = new FlxTrail(this, null, 5, 0, 0.15, 0);

		applyAbility();
		trace("created player with: " + ability + " ability");
	}

	public function applyAbility() {
		maxSpeed = baseMaxSpeed;

		switch (ability) {
			case "none":
				setTrailColor(FlxColor.GRAY);
				abilityIndicator.visible = false;

			case "jump":
				maxJumpAmm++;
				jumpAmm = maxJumpAmm;
				setTrailColor(FlxColor.BLUE);
				abilityIndicator.color = FlxColor.BLUE;

			case "speed":
				setTrailColor(FlxColor.RED);
				abilityIndicator.color = FlxColor.RED;

			case "dash":
				setTrailColor(FlxColor.ORANGE);
				abilityIndicator.color = FlxColor.ORANGE;

			case "time":
				setTrailColor(FlxColor.CYAN);
				abilityIndicator.color = FlxColor.CYAN;

			case "immunity":
				immune = true;
				setTrailColor(FlxColor.YELLOW);
				abilityIndicator.visible = true;
				abilityIndicator.color = FlxColor.YELLOW;

			case "gravity":
				setTrailColor(FlxColor.PURPLE);
				abilityIndicator.color = FlxColor.PURPLE;
		}
	}

	function setTrailColor(color:FlxColor) {
		if (trail != null)
			trail.color = color;
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

			FlxG.timeScale = 1;
			slowdown = false;
			dashing = false;
			dashTimer = 0;
		}
	}

	function updateAbility(elapsed:Float) {
		var abilityPressed = controls.getPressed("player_ability");
		var abilityJustPressed = controls.getJustPressed("player_ability");
		var abilityJustReleased = controls.getJustReleased("player_ability");

		switch (ability) {
			case "speed":
				maxSpeed = abilityPressed ? Std.int(baseMaxSpeed * 1.5) : baseMaxSpeed;

				if (abilityJustPressed)
					boostSfx.play();

				maxVelocity.x = maxSpeed;
				drag.x = maxVelocity.x * 4;
				abilityIndicator.visible = !abilityPressed;

			case "jump":
				abilityIndicator.visible = jumpAmm > 0;

			case "dash":
				if (abilityJustPressed && dashAvailable && !dashing) {
					dashing = true;
					dashAvailable = false;
					dashTimer = dashDuration;
					boostSfx.play();

					velocity.x += dashSpeed * (flipX ? -1 : 1);
					maxVelocity.x = dashSpeed;
					immune = true;

					FlxFlicker.flicker(this, dashDuration, 0.05, true);
				}

				abilityIndicator.visible = dashAvailable;

			case "time":
				if (abilityJustPressed)
					stopSfx.play();

				if (abilityPressed && timeTimer >= 0) {
					FlxG.timeScale = CoolUtil.fpsLerp(FlxG.timeScale, timeScale, 0.1);
					abilityIndicator.visible = false;
					slowdown = true;
					timeTimer += elapsed;

					if (timeTimer >= maxTimeCharge) {
						timeTimer = -timeRechargeDuration;
						FlxFlicker.flicker(abilityIndicator, timeRechargeDuration, 0.05, true);
					}
				} else {
					slowdown = false;
					timeTimer += elapsed;

					if (timeTimer >= 0) {
						timeTimer = 0;
						abilityIndicator.visible = true;
					}

					FlxG.timeScale = CoolUtil.fpsLerp(FlxG.timeScale, 1, 0.1);
				}

				if (abilityJustReleased && timeTimer >= 0) {
					timeTimer = -timeRechargeDuration;
					FlxFlicker.flicker(abilityIndicator, timeRechargeDuration, 0.05, true);
				}

			case "immunity":
				if (!immune) {
					immunityTimer += elapsed;

					if (immunityTimer >= immunityCooldown) {
						immune = true;
						immunityTimer = 0;
					}
				}

			case "gravity":
				if (abilityJustPressed && canFlip) {
					switchSfx.play();
					canFlip = false;
					gravityFlipped = !gravityFlipped;
					flipY = gravityFlipped;
					acceleration.y = gravityFlipped ? -normalGravity : normalGravity;
					velocity.y = 0;
				}

				abilityIndicator.visible = canFlip;
		}

		if (dashing) {
			dashTimer -= elapsed;
			velocity.y = 0;

			if (dashTimer <= 0) {
				dashing = false;
				velocity.x *= 0.5;

				acceleration.y = gravityFlipped ? -normalGravity : normalGravity;

				maxVelocity.x = maxSpeed;
				maxVelocity.y = maxSpeed * 2;
				immune = false;
			}
		}

		abilityIndicator.setPosition(x + (width - abilityIndicator.width) / 2, y - 24 + (height - abilityIndicator.height) / 2);
	}

	override public function update(elapsed:Float) {
		if (!playable)
			return;

		updateAbility(elapsed);

		if (dashing) {
			super.update(elapsed);
			return;
		}

		if (controls.getPressed("player_up")) {
			jumpTimer += elapsed;

			if (jumpTimer < 0.025)
				velocity.y = gravityFlipped ? jumpStrength : -jumpStrength;
		}

		if (controls.getJustPressed("player_up") && isGrounded())
			jumpSfx.play();

		if (controls.getJustReleased("player_up") && jumpTimer < maxJumpTime) {
			velocity.y += 200;
			jumpTimer = maxJumpTime;
		}

		if (controls.getJustPressed("player_up") && !isGrounded() && jumpAmm > 0) {
			jumpSfx.pitch += 0.1;
			jumpSfx.play();

			velocity.y = gravityFlipped ? jumpStrength : -jumpStrength;
			jumpAmm--;
			jumpTimer = 0;

			FlxTween.cancelTweensOf(this);
			angle = 0;

			FlxTween.tween(this, {angle: -360}, 0.5, {
				ease: FlxEase.cubeOut
			});
		}

		if (isGrounded()) {
			jumpAmm = maxJumpAmm;
			dashAvailable = true;
			angle = 0;
			jumpSfx.pitch = 1;
			jumpTimer = 0;
			canFlip = true;
		}

		if (controls.getJustPressed("player_down") && !isGrounded()) {
			velocity.y = gravityFlipped ? -poundStrength : poundStrength;
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

	public function isGrounded():Bool {
		return gravityFlipped ? isTouching(0x0100) : isTouching(0x1000);
	}
}
