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

			case "down", "left", "right", "up":
				makeGraphic(32, 32, FlxColor.WHITE);
				setGraphicSize(32, 32);
				this.color = FlxColor.ORANGE;

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
				shootNormal(x, y);
			case "fast":
				shootFast(x, y);
			case "down", "left", "up", "right":
				shootDir(this.type);
			case "door":
				shootDoor(x, y);
			case "rotate":
				shootRotate(x, y);
		}
	}

	function shootNormal(x:Float, y:Float) {
		var dx = x - this.x;
		var dy = y - this.y;
		var length = Math.sqrt(dx * dx + dy * dy);
		var speed = 100;

		var bullet = new FlxNestedSprite(this.x, this.y);
		bullet.makeGraphic(8, 8, FlxColor.CYAN);
		bullet.relativeX = 12;
		bullet.relativeY = 12;
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

	function shootFast(x:Float, y:Float) {
		var dx = x - this.x;
		var dy = y - this.y;
		var length = Math.sqrt(dx * dx + dy * dy);
		var speed = 200;

		var bullet = new FlxNestedSprite(this.x, this.y);
		bullet.makeGraphic(8, 8, FlxColor.BLUE);
		bullet.relativeX = 12;
		bullet.relativeY = 12;
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
		if (dir == "down") {
			bullet.relativeVelocity.x = 0;
			bullet.relativeVelocity.y = speed;
		}

		if (dir == "up") {
			bullet.relativeVelocity.x = 0;
			bullet.relativeVelocity.y = speed * -1;
		}

		if (dir == "right") {
			bullet.relativeVelocity.x = speed;
			bullet.relativeVelocity.y = 0;
		}

		if (dir == "left") {
			bullet.relativeVelocity.x = speed * -1;
			bullet.relativeVelocity.y = 0;
		}

		FlxTween.num(0, 2, 2, {
			onComplete: function(_) {
				if (bullet != null && bullet.alive) {
					bullet.destroy();

					this.remove(bullet);
				}
			}
		});
	}

	function shootDoor(x:Float, y:Float) {
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
			}

			if (FlxG.overlap(bullet, player)) {
				if (onHit != null)
					onHit();
			}

			if (door != null && door.alive) {
				if (FlxCollision.pixelPerfectCheck(player, door)) {
					if (onHit != null)
						onHit();
				}
			}
		}
	}

	public function lookAt(x:Float, y:Float) {
		var dx = x - (this.x + this.width / 2);
		var dy = y - (this.y + this.height / 2);

		cannonSprite.relativeAngle = Math.atan2(dy, dx) * 180 / Math.PI;
	}
}
