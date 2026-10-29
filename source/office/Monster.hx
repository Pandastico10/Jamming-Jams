class Monster {
	public var type:String;
	public var aiLevel:Int;

	public var lDoor:Bool = false;
	public var rDoor:Bool = false;
	public var lFlash:Bool = false;
	public var rFlash:Bool = false;
	public var lBehind:Bool = false;
	public var fOn:Bool = false;

	public var gotcha:Bool = false;

	public var moveTimer:Float = 0;
	public var movementInterval:Float;

	public var attackTimer:Float = 0;
	public var attackTime:Float = 10;
	public var attackReady:Bool = false;
	public var lookedBehindDuringAttack:Bool = false;

	public var defenseTimer:Float = 0;
	public var defenseTime:Float = 0.5;

	public var curStage:Int = 0;

	public var stunned:Bool = false;
	public var stunTimer:Float = 0;

	public var variation:String = "normal";
	public var movementSound:FlxSound;
	public var scareSound:FlxSound;
	public var blockSound:FlxSound;

	public function new(type:String, aiLevel:Int = 0) {
		this.type = type;
		this.aiLevel = aiLevel;

		movementInterval = 15 - (10 / 19) * (aiLevel - 1);

		if (type == "left" || type == "right") {
			movementInterval += FlxG.random.float(0, 7.5);
			movementInterval *= 2;
		}

		if (type == "left" || type == "right") {
			movementSound = FlxG.sound.load(Paths.music(type + "0"), 0.8);
			scareSound = FlxG.sound.load(Paths.sound("scare"), 0.8);
			blockSound = FlxG.sound.load(Paths.sound("sfxBlock"), 0.8);
		} else if (type == "back") {
			scareSound = FlxG.sound.load(Paths.sound("scare"), 0.8);
		}

		trace(this.type + " movementInterval is " + movementInterval);
	}

	public function tryMove():Bool {
		return !stunned && !attackReady && FlxG.random.int(1, 20) <= aiLevel;
	}

	public function advance():Bool {
		//if at stage 5 do not advance
		if (type == "back" && curStage >= 5)
			return false;

		if ((type == "left" || type == "right") && curStage >= 1)
			return false;

		curStage++;

		//if at stage 4 stage +1 then begin attack
		if (type == "back" && curStage >= 5)
			beginAttack();

		if ((type == "left" || type == "right") && curStage >= 1)
			beginAttack();

		return true;
	}

	public function beginAttack() {
		if (attackReady)
			return;

		attackReady = true;
		attackTimer = 0;
		lookedBehindDuringAttack = false;
		rollVariation();

		trace(type + " is ready to attack as " + variation);
	}

	public function rollVariation() {
		if (aiLevel <= 10)
			return;

		if (type == "back") {
			variation = switch (FlxG.random.weightedPick([70, 30])) {
				case 0: "normal";
				case 1: "inverse";
			};
		} else if (type == "left" || type == "right") {
			variation = switch (FlxG.random.weightedPick([50, 25, 25, 25])) {
				case 0: "normal";
				case 1: "inverse";
				case 2: "flash";
				case 3: "inverseflash";
			};
		}
	}

	public function checkDefense():Bool {
		switch (type) {
			case "back":
				if (variation == "normal")
					return fOn && lBehind;

				if (variation == "inverse")
					return !fOn && !lBehind && lookedBehindDuringAttack;

			case "left":
				if (variation == "normal")
					return lDoor;

				if (variation == "inverse")
					return rDoor;

				if (variation == "flash")
					return lFlash;

				if (variation == "inverseflash")
					return rFlash;

			case "right":
				if (variation == "normal")
					return rDoor;

				if (variation == "inverse")
					return lDoor;

				if (variation == "flash")
					return rFlash;

				if (variation == "inverseflash")
					return lFlash;
		}

		return false;
	}

	public function resolveAttack() {
		var usedDoor:Bool = false;

		switch (type) {
			case "left":
				usedDoor = variation == "normal" ? lDoor : variation == "inverse" && rDoor;

			case "right":
				usedDoor = variation == "normal" ? rDoor : variation == "inverse" && lDoor;
		}

		attackReady = false;
		attackTimer = 0;
		defenseTimer = 0;
		lookedBehindDuringAttack = false;
		curStage = 0;
		moveTimer = 0;

		trace(type + " attack defended!");

		if (usedDoor)
			playPannedSound("sfxBlock");
		else
			playPannedSound("scare");

		stun(getStunDuration());
	}

	public function retreat():Bool {
		if (curStage <= 0 || attackReady)
			return false;

		curStage--;

		if (curStage == 0 && type == "back")
			stun(getStunDuration());

		return true;
	}

	public function getStunDuration():Float {
		var duration:Float;

		if (aiLevel <= 4)
			duration = 12.5;
		else if (aiLevel <= 8)
			duration = 10;
		else if (aiLevel <= 12)
			duration = 7.5;
		else
			duration = 5;

		if (type == "left" || type == "right")
			duration *= 2;

		return duration;
	}

	public function stun(duration:Float) {
		stunned = true;
		stunTimer = duration;

		trace("oh shit the " + type + " monster got stunned for " + duration + " seconds!");
	}

	public function update(elapsed:Float) {
		if (stunned) {
			if (!(type == "back" && fOn && lBehind)) {
				stunTimer -= elapsed;

				if (stunTimer <= 0) {
					stunTimer = 0;
					stunned = false;
					trace(type + " is no longer stunned");
				}
			}

			return;
		}

		if (!attackReady)
			return;

		if (type == "back" && lBehind)
			lookedBehindDuringAttack = true;

		if (checkDefense()) {
			defenseTimer += elapsed;

			if (defenseTimer >= defenseTime) {
				resolveAttack();
				return;
			}
		} else {
			defenseTimer = 0;
		}

		attackTimer += elapsed;

		if (attackTimer >= attackTime) {
			gotcha = true;
			trace(type + " caught you!");
		}
	}

	public function playPannedSound(sound:String) {
		var s:FlxSound = switch (sound) {
			case "scare": scareSound;
			case "sfxBlock": blockSound;
			case "left0", "right0": movementSound;
			default: null;
		};

		if (s == null)
			return;

		s.pan = type == "left" ? -0.5 : type == "right" ? 0.5 : 0;
		s.play(true);
	}
}
