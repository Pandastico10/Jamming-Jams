import flixel.addons.display.FlxNestedSprite;
import flixel.util.FlxCollision;

class Cannon extends FlxNestedSprite {
	public var type:String;
	public var door:FlxNestedSprite;
	public var toggle:Bool = false;
	public var cannonSprite:FlxNestedSprite;

	public function new(x:Float, y:Float, type:String = "normal") {
		super(x, y);

		this.type = type;

		switch (this.type) {
			case "normal":
				makeGraphic(32, 32, FlxColor.TRANSPARENT);
				setGraphicSize(32, 32);
				setup(FlxColor.CYAN);
			case "fast":
				// this.color = FlxColor.BLUE;
				makeGraphic(32, 32, FlxColor.TRANSPARENT);
				setGraphicSize(32, 32);
				setup(FlxColor.BLUE);
			case "right":
				makeGraphic(32, 32, FlxColor.WHITE);
				setGraphicSize(32, 32);
				this.color = FlxColor.ORANGE;
				angle = 0;
			case "down":
				makeGraphic(32, 32, FlxColor.WHITE);
				setGraphicSize(32, 32);
				this.color = FlxColor.ORANGE;
				angle = 90;
			case "left":
				makeGraphic(32, 32, FlxColor.WHITE);
				setGraphicSize(32, 32);
				this.color = FlxColor.ORANGE;
				angle = 180;
			case "up":
				makeGraphic(32, 32, FlxColor.WHITE);
				setGraphicSize(32, 32);
				this.color = FlxColor.ORANGE;
				angle = -90;
			case "door":
				makeGraphic(32, 32, FlxColor.WHITE);
				setGraphicSize(32, 32);
				this.color = FlxColor.LIME;
			case "hazard":
				makeGraphic(32, 32, FlxColor.WHITE);
				setGraphicSize(32, 32);
				this.color = FlxColor.RED;

				var hazard = new FlxNestedSprite(this.x, this.y);
				hazard.makeGraphic(16, 16, FlxColor.PINK);
				hazard.relativeX = 8;
				hazard.relativeY = 8;
				hazard.relativeAlpha = 0;
				hazard.updateHitbox();
				this.add(hazard);
			case "rotate":
				makeGraphic(32, 32, FlxColor.TRANSPARENT);
				setup(FlxColor.PINK);
				setGraphicSize(32, 32);
		}
	}

	public function setup(col:FlxColor) {
		cannonSprite = new FlxNestedSprite(this.x, this.y);
		cannonSprite.makeGraphic(32, 32, col);
		cannonSprite.color = col;
		cannonSprite.relativeX = 0;
		cannonSprite.relativeY = 0;
		cannonSprite.relativeAngle = 0;
		cannonSprite.updateHitbox();
		this.add(cannonSprite);
	}

	public function shoot(x:Float, y:Float) {
		// ill take out color out of here someday but im too lazy to do it now blehhhh
		switch (this.type) {
			case "normal":
				shootTarget(x, y, 100, FlxColor.CYAN);
			case "fast":
				shootTarget(x, y, 200, FlxColor.BLUE);
			case "down", "left", "up", "right":
				shootDir(this.type);
			case "door":
				shootDoor();
			case "rotate":
				shootRotate();
		}
	}

	function shootTarget(x:Float, y:Float, speed:Float, color:FlxColor) {
		var dx = x - this.x;
		var dy = y - this.y;
		var length = Math.sqrt(dx * dx + dy * dy);

		var bullet = new FlxNestedSprite(this.x, this.y);
		bullet.makeGraphic(8, 8, color);
		bullet.relativeX = 12;
		bullet.relativeY = 12;
		bullet.updateHitbox();

		this.add(bullet);

		bullet.relativeVelocity.x = dx / length * speed;
		bullet.relativeVelocity.y = dy / length * speed;

		FlxTween.num(0, 2, 2, {
			onComplete: function(_) {
				if (bullet != null && bullet.alive) {
					bullet.destroy();

					this.remove(bullet);
				}
			}
		});
	}

	function shootDir(dir:String) {
		var speed = 100;

		var bullet = new FlxNestedSprite(this.x, this.y);
		bullet.makeGraphic(8, 8, FlxColor.RED);
		bullet.relativeX = 12;
		bullet.relativeY = 12;
		this.add(bullet);
		// ok so i realized too late that i could move the angle of the parent instead of moving the entire fucking velodity but whatever
		bullet.relativeVelocity.x = speed;

		FlxTween.num(0, 2, 2, {
			onComplete: function(_) {
				if (bullet != null && bullet.alive) {
					bullet.destroy();

					this.remove(bullet);
				}
			}
		});
	}

	function shootDoor() {
		toggle = !toggle;

		if (toggle) {
			door = new FlxNestedSprite(this.x, this.y);
			door.makeGraphic(16, 96, FlxColor.GREEN);
			door.relativeX = 8;
			door.relativeY = 32;
			door.updateHitbox();
			this.add(door);
		} else {
			if (door != null) {
				this.remove(door);
				door.destroy();
				door = null;
			}
		}
	}

	function shootRotate() {
		var speed = 200;

		var bullet = new FlxNestedSprite(this.x, this.y);
		bullet.makeGraphic(8, 8, FlxColor.PINK);
		bullet.relativeX = 12;
		bullet.relativeY = 12;
		bullet.updateHitbox();
		this.add(bullet);
		cannonSprite.relativeAngularVelocity = 50;
		var angle = -cannonSprite.angle * Math.PI / 180;

		bullet.relativeVelocity.x = speed * Math.sin(angle);
		bullet.relativeVelocity.y = speed * Math.cos(angle);

		FlxTween.num(0, 2, 2, {
			onComplete: function(_) {
				if (bullet != null && bullet.alive) {
					bullet.destroy();

					this.remove(bullet);
				}
			}
		});
	}

	public function updateBullets(player:FlxObject, boxes:FlxBasic, ?onHit:() -> Void) {
		for (bullet in this.children) {
			if (FlxG.overlap(bullet, boxes)) {
				this.remove(bullet);
				bullet.destroy();
				continue;
			}
			if (FlxG.overlap(bullet, player)) {
				if (onHit != null)
					onHit();
				return;
			}
		}
		if (door != null && door.alive && FlxCollision.pixelPerfectCheck(player, door)) {
			if (onHit != null)
				onHit();
		}
	}

	public function lookAt(x:Float, y:Float) {
		var dx = x - (this.x + this.width / 2);
		var dy = y - (this.y + this.height / 2);

		cannonSprite.relativeAngle = Math.atan2(dy, dx) * 180 / Math.PI;
	}
}
