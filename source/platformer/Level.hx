import flixel.util.FlxSpriteUtil;
import openfl.Assets;
import flixel.group.FlxGroup;
import haxe.io.Path;
import platformer.Cannon;
import platformer.DeathCounter;
import Xml;

class Level {
	public var level:String = "level0";
	public var music:String = "field";
	public var bpm:Int = 136;
	public var aiLvl:Int = 0;
	public var levelWidth:Int = 0;
	public var deaths:Int = 0;

	public var playerX:Int = 0;
	public var playerY:Int = 64;
	public var maxJumpAmm:Int = 1;

	public var cannons:FlxGroup;
	public var boxes:FlxGroup;
	public var eventBoxes:FlxGroup;

	public var stages:Array<String> = [];
	public var stageBoxes:Array<Array<Dynamic>> = [];
	public var stageCannons:Array<Array<Dynamic>> = [];
	public var stageEvents:Array<Array<Dynamic>> = [];

	public var curStage:Int = 0;
	public var gridSize:Int = 32;

	public var camGame:FlxCamera;

	var wideLevel:Bool = false;

	public function new(levelFile:String = "current", ?camera:FlxCamera) {
		camGame = camera != null ? camera : FlxG.camera;

		cannons = new FlxGroup();
		boxes = new FlxGroup();
		eventBoxes = new FlxGroup();

		loadLevelInfo(levelFile);

		deaths = DeathCounter.load(level);

		wideLevel = levelWidth > 768;

		loadStage(curStage);
	}

	public function update(player:FlxObject) {
		if (wideLevel)
			FlxSpriteUtil.screenWrap(player, false, false);
		else
			FlxSpriteUtil.screenWrap(player);

		FlxG.collide(boxes, player);

		updateCannons(player);
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
		if (curStage > stages.length - 1) return;

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
			cannon.cameras = [camGame];
			cannons.add(cannon);
		}
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

		boxes.clear();
		eventBoxes.clear();
		cannons.clear();
	}

	public function death(player:FlxObject) {
		player.x = playerX;
		player.y = playerY;

		FlxG.sound.play(Paths.sound("sfxDeath"));
		deaths = DeathCounter.add(level);
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
		bpm = Std.parseInt(xml.get("bpm"));
		aiLvl = Std.parseInt(xml.get("aiLvl"));
		levelWidth = Std.parseInt(xml.get("levelWidth"));

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
