import office.Monster;

class Manager {
	public var monsters:Array<Monster> = [];

	public var flashTimer:Float = 0;
	public var flashInterval:Float = 1.5;

	public var gotcha:Bool = false;

	public var lDoor:Bool = false;
	public var rDoor:Bool = false;
	public var lFlash:Bool = false;
	public var rFlash:Bool = false;
	public var lBehind:Bool = false;
	public var fOn:Bool = false;

	public function new(leftAi:Int = 0, rightAi:Int = 0, backAi:Int = 0, upAi:Int = 0) {
		if (leftAi > 0)
			monsters.push(new Monster("left", leftAi));

		if (rightAi > 0)
			monsters.push(new Monster("right", rightAi));

		if (backAi > 0)
			monsters.push(new Monster("back", backAi));

		if (upAi > 0)
			monsters.push(new Monster("up", upAi));
	}

	public function updateDefenses(leftDoor:Bool, rightDoor:Bool, lookingBehind:Bool, flashOn:Bool, leftFlash:Bool, rightFlash:Bool) {
		lDoor = leftDoor;
		rDoor = rightDoor;
		lFlash = leftFlash;
		rFlash = rightFlash;
		lBehind = lookingBehind;
		fOn = flashOn;

		for (mon in monsters) {
			mon.lDoor = leftDoor;
			mon.rDoor = rightDoor;
			mon.lBehind = lookingBehind;
			mon.fOn = flashOn;
			mon.lFlash = leftFlash;
			mon.rFlash = rightFlash;
		}
	}

	public function update(elapsed:Float) {
		if (gotcha)
			return;

		if (fOn && lBehind) {
			flashTimer += elapsed;

			if (flashTimer >= flashInterval) {
				flashTimer -= flashInterval;

				for (mon in monsters) {
					if (mon.type != "back" || mon.attackReady || !mon.retreat())
						continue;

					mon.moveTimer = 0;

					if (mon.curStage > 0)
						FlxG.sound.play(Paths.sound("back" + (mon.curStage - 1)));
					else if (mon.curStage == 0)
						FlxG.sound.play(Paths.sound("scare"));

					trace(mon.type + " retreated to stage " + mon.curStage);
				}
			}
		} else {
			flashTimer = 0;
		}

		for (mon in monsters) {
			mon.update(elapsed);

			if (mon.gotcha) {
				gotcha = true;
				return;
			}

			if (mon.type == "back" && fOn && lBehind)
				continue;

			if (mon.stunned || mon.attackReady)
				continue;

			mon.moveTimer += elapsed;

			if (mon.moveTimer < mon.movementInterval)
				continue;

			mon.moveTimer -= mon.movementInterval;

			if (!mon.tryMove())
				continue;

			if (mon.advance()) {
				if (mon.type == "back")
					FlxG.sound.play(Paths.sound("back" + (mon.curStage - 1)));

				if (mon.type == "left")
					mon.playPannedSound("left0");

				if (mon.type == "right")
					mon.playPannedSound("right0");

				trace(mon.type + " advanced to stage " + mon.curStage);

				if (mon.attackReady)
					trace(mon.type + " entered the attack phase!");
			}
		}
	}
}
