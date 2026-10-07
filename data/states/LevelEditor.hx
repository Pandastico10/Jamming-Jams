import funkin.editors.ui.UIState;
import funkin.editors.EditorTreeMenu;
import funkin.editors.ui.UITopMenu;
import funkin.editors.ui.UIUtil;
import funkin.editors.ui.UISliceSprite;
import funkin.editors.ui.UISoftcodedWindow;
import flixel.util.FlxSpriteUtil;
import funkin.editors.SaveSubstate;
import flixel.input.keyboard.FlxKey;
import haxe.xml.Access;
import haxe.xml.Printer;
import haxe.io.Path;
import platformer.Player;
import platformer.Cannon;
import Xml;

// is making every single variable public bad??
// idk
// probably but hey i can script events easier like this
public var level:String = "level0";
public var music:String = "field";
var levelWidth:Int = 0;
public var bpm:Int = 136;
public var aiLvl:Int = 0;

// player vars default
public var playerX:Int = 0;
public var playerY:Int = 64;
public var maxJumpAmm:Int = 1;

// ini sprites
public var player:Player;
public var cannon:Cannon;
public var blend = new FlxSprite();
public var blend1 = new FlxSprite();
public var debugLayer = new FlxGroup();
public var toolSprites = new FlxGroup();
public var stageTxt:FlxText;

// groups & other stuff
public var stages:Array<String> = [];

// dont forget to add these cases to the switch on mouse JustPressed!
public var tools:Array<String> = [
	"box", "normal", "fast", "down", "door", "up", "left", "right", "hazard", "next", "rotate", "spawn"
];

public var curSelected:Int = 0;
public var stageBoxes:Array<Array<Dynamic>> = [[]];
public var stageCannons:Array<Array<Dynamic>> = [[]];
public var stageEvents:Array<Array<Dynamic>> = [[]];
public var boxes:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();
public var eventBoxes:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();
public var cannons:FlxTypedGroup<Cannon> = new FlxTypedGroup<Cannon>();
public var camGame:FlxCamera = new FlxCamera();
public var cols:Int;
public var rows:Int;
public var camHud:FlxCamera = new FlxCamera();
public var topMenu:Array<UIContextMenuOption>;
public var topMenuSpr:UITopMenu;

// rest
public var gridToggle:Bool = false;
public var gridSize:Int = 32;
public var curStage:Int = 0;

function create() {
	loadLevelInfo();

	// trace("LEVEL: " + level);
	// trace("MUSIC: " + music);
	// trace("BPM: " + bpm);
	// trace("PlayerX: " + playerX);
	// trace("PlayerY: " + playerY);
	// trace("MaxJumpAmm: " + maxJumpAmm);
	// trace("Stages: " + stages);
	// trace("Boxes: " + stageBoxes);
	loadStage(curStage);
	player = new Player(playerX, playerY);
	topMenu = [
		{
			label: "File",
			childs: [
				{
					label: "Save",
					keybind: [FlxKey.CONTROL, FlxKey.S],
					onSelect: file_save,
				},
				{
					label: "Save As",
					keybind: [FlxKey.CONTROL, FlxKey.SHIFT, FlxKey.S],
					onSelect: file_saveas,
				},
				{
					label: "Exit",
					keybind: [FlxKey.CONTROL, FlxKey.E],
					onSelect: file_exit,
				}
			]
		},
		{
			label: "Edit",
			childs: [
				{
					label: "Edit Level Info",
					onSelect: (_) -> {
						openSubState(new UISoftcodedWindow("levelInfoScreen", [
							"winTitle" => "Editing Level Info",
							"level" => level,
							"music" => music,
							"bpm" => bpm,
							"maxJumpAmm" => player.maxJumpAmm,
							"playerX" => playerX,
							"playerY" => playerY,
							"aiLvl" => aiLvl,
							"levelWidth" => levelWidth,
							"applyInfo" => function(newLevel:String, newMusic:String, newBpm:Int, newX:Int, newY:Int, newJumps:Int, newAi:Int, newWidth:Int) {
								level = newLevel;
								music = newMusic;
								bpm = newBpm;

								playerX = newX;
								playerY = newY;
								maxJumpAmm = newJumps;
								player.maxJumpAmm = newJumps;
								aiLvl = newAi;
								levelWidth = newWidth;
							}
						]));
					}
				},
				{
					label: "Set # of stages",
					onSelect: (_) -> {
						openSubState(new UISoftcodedWindow("stageNumberScreen", [
							"winTitle" => "Editing Stage Number",
							"stages" => stages.length,
							"applyInfo" => function(stageNumbers:Int) {
								var oldStageBoxes = stageBoxes;
								var oldStageCannons = stageCannons;
								var oldStageEvents = stageEvents;

								stages = [];

								for (i in 0...stageNumbers)
									stages.push("stage" + i);

								stageBoxes = [];
								stageCannons = [];
								stageEvents = [];

								for (i in 0...stageNumbers) {
									if (i < oldStageBoxes.length)
										stageBoxes.push(oldStageBoxes[i]);
									else
										stageBoxes.push([]);

									if (i < oldStageCannons.length)
										stageCannons.push(oldStageCannons[i]);
									else
										stageCannons.push([]);

									if (i < oldStageEvents.length)
										stageEvents.push(oldStageEvents[i]);
									else
										stageEvents.push([]);
								}

								if (curStage >= stageNumbers)
									curStage = stageNumbers - 1;

								loadStage(curStage);
							}
						]));
					}
				}
			]
		},
		{
			label: "Misc",
			childs: [
				{
					label: "Toggle grid",
					keybind: [FlxKey.CONTROL, FlxKey.ONE],
					onSelect: toggleGrid,
					icon: gridToggle ? 1 : 0
				},
				{
					label: "Test Level",
					keybind: [FlxKey.CONTROL, FlxKey.TWO],
					onSelect: startTest,
				}
			]
		},
		{
			label: "Stages",
			childs: [
				{
					label: "Previous stage",
					keybind: [FlxKey.O],
					onSelect: pStage,
				},
				{
					label: "Next Stage",
					keybind: [FlxKey.P],
					onSelect: nStage,
				},
				null,
				{
					label: "Copy last Stage",
					keybind: [FlxKey.I],
					onSelect: copyStage,
				}
			]
		}
	];

	CoolUtil.playMusic(Paths.music(music), true, 0.8, true, bpm);
	FlxG.cameras.add(camGame, true);
	camGame.bgColor = 0;
	FlxG.cameras.add(camHud, false);
	camHud.bgColor = 0;

	blend1.makeGraphic(FlxG.width + 1100, FlxG.height, 0xFF000000);
	add(blend1);
	blend.makeGraphic(FlxG.width + 1100, FlxG.height, 0xFF1F1F1F);
	blend.alpha = 0;
	add(blend);

	for (i in 0...tools.length) {
		var name = 'box' + i;
		var name = new FlxSprite().makeGraphic(gridSize, gridSize, 0xFFFFFFFF);
		toolSprites.add(name);
	}

	for (sprites in toolSprites) {
		sprites.visible = false;
		sprites.alpha = 0.25;
		add(sprites);
	}

	toolSprites.members[curSelected].visible = true;

	add(cannons);
	add(boxes);
	add(eventBoxes);
	add(player);
	cols = Std.int(camGame.width / gridSize);
	rows = Std.int(camGame.height / gridSize);
	if (levelWidth > 768) {
		camGame.setScrollBoundsRect(0, 0, levelWidth, camGame.height, true);
		camGame.follow(player);
		camGame.followLerp = 0.05;
		cols = Std.int(levelWidth / gridSize);
	}

	for (i in [player, cannons, boxes, blend, eventBoxes])
		i.cameras = [camGame];

	for (row in 0...rows + 1) {
		var lineH = new FlxSprite(0, row * gridSize);
		lineH.makeGraphic(cols * gridSize, 2, FlxColor.YELLOW);
		lineH.alpha = 0.5;
		debugLayer.add(lineH);
	}
	for (col in 0...cols + 1) {
		var lineV = new FlxSprite(col * gridSize, 0);
		lineV.makeGraphic(2, rows * gridSize, FlxColor.YELLOW);
		lineV.alpha = 0.5;
		debugLayer.add(lineV);
	}
	debugLayer.cameras = [camGame];
	debugLayer.visible = gridToggle;
	add(debugLayer);
	stageTxt = new FlxText(0, 0, FlxG.width, "Stage 0");
	stageTxt.setFormat(null, 32, FlxColor.WHITE, 'CENTER');
	stageTxt.cameras = [camHud];
	stageTxt.screenCenter();
	stageTxt.alpha = 0;
	add(stageTxt);
	select(0);
	topMenuSpr = new UITopMenu(topMenu);
	topMenuSpr.cameras = [camHud];
	add(topMenuSpr);
}

function update(elapsed:Float) {
	var mouse = FlxG.mouse.getWorldPosition(camGame);
	var mouseX = Std.int(mouse.x / gridSize) * gridSize;
	var mouseY = Std.int(mouse.y / gridSize) * gridSize;
	if (FlxG.keys.justPressed.ANY)
		UIUtil.processShortcuts(topMenu);
	if (FlxG.keys.justPressed.Y)
		select(1);
	if (FlxG.keys.justPressed.T)
		select(-1);
	// i just found this exists this is so cool???

	if (levelWidth > 768) {
		FlxSpriteUtil.screenWrap(player, false, false);
		blend.x = player.x - (blend.width / 2);
		blend1.x = player.x - (blend1.width / 2);
	} else {
		FlxSpriteUtil.screenWrap(player);
	}
	// check collisions
	FlxG.collide(eventBoxes, player, nextStage);
	FlxG.collide(boxes, player);
	for (cannon in cannons.members) {
		// disable this if lag
		// if save dadta stuff yeah
		if (cannon.type == "normal" || cannon.type == "fast") {
			cannon.lookAt(player.x + player.width / 2, player.y + player.height / 2);
		}
		cannon.updateBullets(player, boxes, death);
	}

	for (sprites in toolSprites) {
		sprites.x = mouseX;
		sprites.y = mouseY;
	}

	if (FlxG.mouse.justPressed) {
		switch (curSelected) {
			case 0:
				var existing:FlxSprite = null;

				for (cube in boxes.members) {
					if (cube != null && cube.x == mouseX && cube.y == mouseY) {
						existing = cube;
						break;
					}
				}

				if (existing != null) {
					boxes.remove(existing, true);
					existing.destroy();
				} else {
					var cube = new FlxSprite(mouseX, mouseY);
					cube.makeGraphic(gridSize, gridSize, 0xFFFFFFFF);
					cube.immovable = true;
					boxes.add(cube);
				}

			case 1, 2, 3, 4, 5, 6, 7, 8, 10:
				var existing:Cannon = null;

				for (cannon in cannons.members) {
					if (cannon != null && cannon.x == mouseX && cannon.y == mouseY) {
						existing = cannon;
						break;
					}
				}

				if (existing != null) {
					cannons.remove(existing, true);
					existing.destroy();
				} else {
					var cannon = new Cannon(mouseX, mouseY, tools[curSelected]);
					cannons.add(cannon);
				}
			case 9:
				var existing:FlxSprite = null;

				for (event in eventBoxes.members) {
					if (event != null && event.x == mouseX && event.y == mouseY) {
						existing = event;
						break;
					}
				}

				if (existing != null) {
					eventBoxes.remove(existing, true);
					existing.destroy();
				} else {
					var event = new FlxSprite(mouseX, mouseY);
					event.makeGraphic(gridSize, gridSize, 0xFF00FF00);
					event.immovable = true;
					eventBoxes.add(event);
				}
			case 11:
				playerX = mouseX;
				playerY = mouseY;
				player.x = mouseX;
				player.y = mouseY;
		}
	}
}

function select(cur:Int) {
	curSelected = FlxMath.wrap(curSelected + cur, 0, tools.length - 1);
	for (sprites in toolSprites)
		sprites.visible = false;
	toolSprites.members[curSelected].visible = true;
	text("Selected " + tools[curSelected]);
}

function measureHit(curMeasure:Int) {
	FlxTween.cancelTweensOf(blend);

	// eventually replace these with fadeout()
	blend.alpha = 1;

	FlxTween.tween(blend, {alpha: 0}, 1, {
		ease: FlxEase.cubeOut
	});
	for (cannon in cannons.members) {
		if (cannon != null && cannon.type == "normal")
			cannon.shoot(player.x, player.y);
		if (cannon != null && cannon.type == "fast")
			cannon.shoot(player.x, player.y);
		if (cannon != null && cannon.type == "door")
			cannon.shoot(player.x, player.y);
	}
}

function beatHit(curBeat:Int) {
	// top tier lazyness here
	if (curBeat % 2 == 0) {
		for (cannon in cannons.members) {
			if (cannon != null && cannon.type == "down")
				cannon.shoot(player.x, player.y);
			if (cannon != null && cannon.type == "left")
				cannon.shoot(player.x, player.y);
			if (cannon != null && cannon.type == "right")
				cannon.shoot(player.x, player.y);
			if (cannon != null && cannon.type == "up")
				cannon.shoot(player.x, player.y);
		}
	}
}

function stepHit(curStep:Int) {
	if (curStep % 4 == 0) {
		for (cannon in cannons.members) {
			if (cannon != null && cannon.type == "rotate")
				cannon.shoot(player.x, player.y);
		}
	}
}

function file_save(_) {
	#if sys
	var data = buildStage();

	CoolUtil.safeSaveFile(Paths.getAssetsRoot() + '/data/levels/' + level + '.xml', data);
	CoolUtil.safeSaveFile(Paths.getAssetsRoot() + '/data/levels/current.xml', data);
	#else
	_file_saveas(_);
	#end
}

function file_saveas(_) {
	// i think this breaks??????
	var data = buildStage();
	openSubState(new SaveSubstate(data, {
		defaultSaveFile: 'level.xml'
	}));
	CoolUtil.safeSaveFile(Paths.getAssetsRoot() + '/data/levels/current.xml', data);
}

function file_exit() {
	FlxG.switchState(new EditorTreeMenu(null, true, "LevelSelector"));
}

function buildStage():String {
	text("Level saved!");
	saveCurrentStage();

	var xml = Xml.createElement("level");

	saveToXml(xml, "name", level);
	saveToXml(xml, "music", music);
	saveToXml(xml, "bpm", bpm);
	saveToXml(xml, "aiLvl", aiLvl);
	saveToXml(xml, "levelWidth", levelWidth);

	var player = Xml.createElement("player");

	saveToXml(player, "x", playerX);
	saveToXml(player, "y", playerY);
	saveToXml(player, "maxJumpAmount", maxJumpAmm);

	xml.addChild(player);

	var stagesXML = Xml.createElement("stages");

	// holy headache
	for (i in 0...stages.length) {
		var stageXML = Xml.createElement("stage");

		saveToXml(stageXML, "name", stages[i]);

		for (data in stageBoxes[i]) {
			var boxXML = Xml.createElement("box");

			saveToXml(boxXML, "x", data.x);
			saveToXml(boxXML, "y", data.y);

			stageXML.addChild(boxXML);
		}
		for (data in stageEvents[i]) {
			var eventXML = Xml.createElement("next");

			saveToXml(eventXML, "x", data.x);
			saveToXml(eventXML, "y", data.y);

			stageXML.addChild(eventXML);
		}

		for (data in stageCannons[i]) {
			var cannonXML = Xml.createElement("cannon");

			saveToXml(cannonXML, "x", data.x);
			saveToXml(cannonXML, "y", data.y);
			saveToXml(cannonXML, "type", data.type);

			stageXML.addChild(cannonXML);
		}

		stagesXML.addChild(stageXML);
	}

	xml.addChild(stagesXML);

	trace("Saved Succesfully!");

	return "<!DOCTYPE jam-level>\n" + Printer.print(xml, true);
}

function saveToXml(xml:Xml, name:String, value:Dynamic, ?defaultValue:Dynamic) {
	if (value == null || value == defaultValue)
		return xml;
	xml.set(name, Std.string(value));
	return xml;
}

function toggleGrid() {
	gridToggle = !gridToggle;
	debugLayer.visible = gridToggle ? true : false;
	text("Grid toggled");
}

function startTest() {
	player.test();
	text("Test started");
}

function death() {
	player.x = playerX;
	player.y = playerY;
	text("you died");
	FlxG.sound.play(Paths.sound("sfxDeath"));
}

function pStage() {
	saveCurrentStage();

	curStage = FlxMath.wrap(curStage - 1, 0, stages.length - 1);
	text("Stage " + curStage);

	loadStage(curStage);
}

function copyStage() {
	if (stages.length > 1) {
		loadStage(curStage - 1);
		text("Copied last stage");
	} else {
		text("Only one stage");
	}
}

function nStage() {
	saveCurrentStage();

	curStage = FlxMath.wrap(curStage + 1, 0, stages.length - 1);
	text("Stage " + curStage);
	loadStage(curStage);
}

function nextStage() {
	// also take this one out in playstate
	saveCurrentStage();
	// remember to eventually not make it loop and have it end the night when reaching stageAmm
	player.x = playerX;
	player.y = playerY;
	curStage = FlxMath.wrap(curStage + 1, 0, stages.length - 1);
	text("Stage " + curStage);

	loadStage(curStage);
}

function saveCurrentStage() {
	stageBoxes[curStage] = [];
	stageCannons[curStage] = [];
	stageEvents[curStage] = [];

	for (cube in boxes.members) {
		if (cube != null) {
			stageBoxes[curStage].push({
				x: cube.x,
				y: cube.y
			});
		}
	}

	for (event in eventBoxes.members) {
		if (event != null) {
			stageEvents[curStage].push({
				x: event.x,
				y: event.y
			});
		}
	}

	for (cannon in cannons.members) {
		if (cannon != null) {
			stageCannons[curStage].push({
				x: cannon.x,
				y: cannon.y,
				type: cannon.type
			});
		}
	}
}

function loadStage(cur:Int) {
	for (cube in boxes.members) {
		if (cube != null)
			cube.destroy();
	}
	for (cube in eventBoxes.members) {
		if (cube != null)
			cube.destroy();
	}

	boxes.clear();
	eventBoxes.clear();

	for (cannon in cannons.members) {
		if (cannon != null)
			cannon.destroy();
	}

	cannons.clear();

	for (data in stageBoxes[cur]) {
		var cube = new FlxSprite(data.x, data.y);
		cube.makeGraphic(gridSize, gridSize, 0xFFFFFFFF);
		cube.immovable = true;
		boxes.add(cube);
	}
	for (data in stageEvents[cur]) {
		var event = new FlxSprite(data.x, data.y);
		event.makeGraphic(gridSize, gridSize, 0xFF00FF00);
		event.immovable = true;
		event.alpha = 0.5;
		eventBoxes.add(event);
	}
	for (data in stageCannons[cur]) {
		var cannon = new Cannon(data.x, data.y, data.type);
		cannon.cameras = [camGame];
		cannons.add(cannon);
	}
}

function text(text:String) {
	FlxTween.cancelTweensOf(stageTxt);
	stageTxt.text = text;
	stageTxt.alpha = 1;
	FlxTween.tween(stageTxt, {alpha: 0}, 1, {
		ease: FlxEase.cubeOut
	});
}

function loadLevelInfo() {
	var xml = Xml.parse(Assets.getText(Paths.xml('levels/current'))).firstElement();

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
					var stageName = stageNode.get("name");

					stages.push(stageName);
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
