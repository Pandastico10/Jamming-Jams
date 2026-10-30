import flixel.util.FlxSpriteUtil;
import flixel.effects.particles.FlxParticle;
import flixel.effects.particles.FlxTypedEmitter;
import openfl.display.BlendMode;
import openfl.Assets;
import flixel.group.FlxGroup;
import haxe.io.Path;
import platformer.Cannon;
import platformer.DeathCounter;
import flixel.effects.FlxFlicker;
import Xml;

class Level {
	public var level:String = "level0";
	public var music:String = "field";
	public var artist:String = "Pandastico";
	public var bpm:Int = 136;
	public var levelWidth:Int = 0;
	public var deaths:Int = 0;
	public var leftAi:Int = 0;
	public var rightAi:Int = 0;
	public var backAi:Int = 0;
	public var upAi:Int = 0;

	public var playerX:Int = 0;
	public var playerY:Int = 64;
	public var maxJumpAmm:Int = 1;

	public var cannons:FlxGroup;
	public var particles:FlxGroup;
	public var boxes:FlxGroup;
	public var eventBoxes:FlxGroup;
	public var backgroundSprites:FlxGroup;
	public var hudElements:FlxGroup;

	public var emitter:FlxTypedEmitter = new FlxTypedEmitter(200, 200, 15);

	public var stages:Array<String> = [];
	public var stageBoxes:Array<Array<Dynamic>> = [];
	public var stageCannons:Array<Array<Dynamic>> = [];
	public var stageEvents:Array<Array<Dynamic>> = [];

	public var deathCounter:FlxText;
	public var timeCounter:FlxText;
	public var stageCounter:FlxText;

	public var curStage:Int = 0;
	public var gridSize:Int = 32;

	public var time:Float = 0;
	public var camGame:FlxCamera;

	var wideLevel:Bool = false;

	public var godmode:Bool = false;

	public var background:FlxSprite;
	public var backgroundTop:FlxSprite;
	public var vignette:FlxSprite;
	public var backgroundOverlay:FlxSprite;
	public var backgroundShader = new CustomShader(FlxG.save.data.bgs);
	public var sfxDeath:FlxSound;

	public function new(levelFile:String = "current", ?camera:FlxCamera) {
		camGame = camera != null ? camera : FlxG.camera;

		cannons = new FlxGroup();
		particles = new FlxGroup();
		boxes = new FlxGroup();
		eventBoxes = new FlxGroup();
		backgroundSprites = new FlxGroup();
		hudElements = new FlxGroup();

		createBackground();
		createHud();
		createParticles();
		loadLevelInfo(levelFile);

		wideLevel = levelWidth > 768;

		loadStage(curStage);
		sfxDeath = FlxG.sound.load(Paths.sound("sfxDeath"), 1, false);
	}

	public function createParticles() {
		emitter.makeParticles(5, 5, FlxColor.RED, 15);
		emitter.lifespan.set(0.3, 0.5);
		emitter.alpha.set(1, 0);
	}

	public function update(player:FlxObject, elapsed:Float) {
		if (wideLevel)
			// warp up and down but not left n right
			FlxSpriteUtil.screenWrap(player, false, false);
		else
			FlxSpriteUtil.screenWrap(player);
		FlxG.collide(boxes, player);
		updateCannons(player);
		time += elapsed;
		backgroundShader.iTime = time;
		// hud elements
		deathCounter.text = "Deaths: " + deaths;
		stageCounter.text = "Stage " + (curStage + 1) + "/" + stages.length;
		timeCounter.text = CoolUtil.timeToStr(time * 1000);
	}

	function updateCannons(player:FlxObject) {
		var playerX = player.x + player.width / 2;
		var playerY = player.y + player.height / 2;

		for (cannon in cannons.members) {
			if (cannon == null)
				continue;

			if (cannon.type == "normal" || cannon.type == "fast")
				cannon.lookAt(playerX, playerY);

			cannon.updateBullets(player, boxes, function() {
				death(player);
			});
		}
	}

	public function loadStage(stage:Int) {
		if (stages.length == 0)
			return;

		curStage += stage;
		if (curStage > stages.length - 1)
			return;

		clearStage();

		for (data in stageBoxes[curStage]) {
			var cube = new FlxSprite(data.x, data.y);
			cube.makeGraphic(gridSize, gridSize, 0xFFFFFFFF);
			cube.immovable = true;
			cube.cameras = [camGame];
			boxes.add(cube);
		}

		for (data in stageEvents[curStage]) {
			var event = new FlxSprite(data.x, data.y);
			event.makeGraphic(gridSize, gridSize, 0xFF00FF00);
			event.immovable = true;
			event.alpha = 0.5;
			event.cameras = [camGame];
			eventBoxes.add(event);
		}

		for (data in stageCannons[curStage]) {
			var cannon = new Cannon(data.x, data.y, data.type);
			particles.add(cannon.emitter);
			cannon.cameras = [camGame];
			cannons.add(cannon);
		}
	}

	function createBackground() {
		background = new FlxSprite();
		background.makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
		background.scrollFactor.set(0, 0);
		background.cameras = [camGame];
		background.visible = true;

		backgroundTop = new FlxSprite();
		backgroundTop.makeGraphic(FlxG.width, FlxG.height, 0xFF131313);
		backgroundTop.alpha = 0;
		backgroundTop.blend = BlendMode.ADD;
		backgroundTop.scrollFactor.set(0, 0);
		backgroundTop.cameras = [camGame];
		backgroundTop.visible = true;

		if (FlxG.save.data.bg) {
			background.shader = backgroundShader;
		}
		vignette = new FlxSprite().loadGraphic(Paths.image("game/vignette"));
		vignette.setGraphicSize(FlxG.width, FlxG.height);
		vignette.screenCenter();
		vignette.scrollFactor.set(0, 0);
		vignette.cameras = [camGame];
		vignette.visible = true;

		backgroundOverlay = new FlxSprite();
		backgroundOverlay.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		backgroundOverlay.alpha = 0.975;
		backgroundOverlay.scrollFactor.set(0, 0);
		backgroundOverlay.cameras = [camGame];
		backgroundOverlay.visible = true;

		backgroundSprites.add(background);
		backgroundSprites.add(vignette);
		backgroundSprites.add(backgroundOverlay);
		backgroundSprites.add(backgroundTop);
	}

	function createHud() {
		deathCounter = new FlxText(0, FlxG.height - 48, FlxG.width, "Deaths: " + deaths);
		JamUtils.setupText(deathCounter, 48, 'left', 'Small.otf');

		timeCounter = new FlxText(FlxG.width - 155, FlxG.height - 48, FlxG.width, CoolUtil.timeToStr(0));
		JamUtils.setupText(timeCounter, 48, 'left', 'Small.otf');

		stageCounter = new FlxText(0, FlxG.height - 48, FlxG.width, "Stage " + (curStage + 1) + "/??");
		JamUtils.setupText(stageCounter, 48, 'center', 'Small.otf');

		hudElements.add(deathCounter);
		hudElements.add(timeCounter);
		hudElements.add(stageCounter);
	}

	function clearStage() {
		for (cube in boxes.members) {
			if (cube != null)
				cube.destroy();
		}

		for (event in eventBoxes.members) {
			if (event != null)
				event.destroy();
		}

		for (cannon in cannons.members) {
			if (cannon != null)
				cannon.destroy();
		}
		for (particle in particles.members) {
			if (particle != null)
				particle.destroy();
		}

		boxes.clear();
		eventBoxes.clear();
		cannons.clear();
		particles.clear();
	}

	public function death(player:FlxObject) {
		if (godmode)
			return;
		if (player.ability == "immunity" && (player.immune || !player.gotHit)) {
			player.gotHit = true;
			if (player.gotHit)
				player.immunitySfx.play();
			FlxFlicker.flicker(player.abilityIndicator, player.immunityCooldown, 0.05, true);
			FlxFlicker.flicker(player, player.immunityDuration, 0.05, true);
			new FlxTimer().start(player.immunityDuration, () -> {
				player.immune = false;
				player.gotHit = false;
			});
			return;
		}
		if (player.ability != "immunity" && player.immune)
			return;

		FlxFlicker.flicker(player, 0.5, 0.05, true);
		sfxDeath.play();
		godmode = true;
		emitter.setPosition(player.x, player.y);
		emitter.start(true);
		player.x = playerX;
		player.y = playerY;
		deaths++;

		new FlxTimer().start(0.25, () -> {
			godmode = false;
		});
	}

	public function shootCannon(type:String, player:FlxObject) {
		for (cannon in cannons.members) {
			if (cannon == null)
				continue;
			if (cannon.type != type)
				continue;
			cannon.shoot(player.x, player.y);
		}
	}

	function loadLevelInfo(levelFile:String) {
		var xml = Xml.parse(Assets.getText(Paths.xml("levels/" + levelFile))).firstElement();

		level = xml.get("name");
		music = xml.get("music");
		artist = xml.get("artist");
		bpm = Std.parseInt(xml.get("bpm"));
		leftAi = Std.parseInt(xml.get("leftAi") ?? "0");
		rightAi = Std.parseInt(xml.get("rightAi") ?? "0");
		backAi = Std.parseInt(xml.get("backAi") ?? "0");
		upAi = Std.parseInt(xml.get("upAi") ?? "0");
		levelWidth = Std.parseInt(xml.get("levelWidth") ?? "0");

		stages = [];
		stageBoxes = [];
		stageCannons = [];
		stageEvents = [];

		for (node in xml.elements()) {
			switch (node.nodeName) {
				case "player":
					playerX = Std.parseInt(node.get("x"));
					playerY = Std.parseInt(node.get("y"));
					maxJumpAmm = Std.parseInt(node.get("maxJumpAmount"));

				case "stages":
					for (stageNode in node.elements()) {
						stages.push(stageNode.get("name"));
						stageBoxes.push([]);
						stageCannons.push([]);
						stageEvents.push([]);

						var stageIndex = stageBoxes.length - 1;

						for (objectNode in stageNode.elements()) {
							switch (objectNode.nodeName) {
								case "box":
									stageBoxes[stageIndex].push({
										x: Std.parseInt(objectNode.get("x")),
										y: Std.parseInt(objectNode.get("y"))
									});

								case "next":
									stageEvents[stageIndex].push({
										x: Std.parseInt(objectNode.get("x")),
										y: Std.parseInt(objectNode.get("y"))
									});

								case "cannon":
									stageCannons[stageIndex].push({
										x: Std.parseInt(objectNode.get("x")),
										y: Std.parseInt(objectNode.get("y")),
										type: objectNode.get("type")
									});
							}
						}
					}
			}
		}
	}
}
