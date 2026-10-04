import funkin.editors.ui.UIButton;
import funkin.editors.ui.UITextBox;
import funkin.editors.ui.UIText;
import funkin.editors.ui.UIFileExplorer;
import funkin.editors.ui.UIAudioPlayer;
import sys.io.File;

var levelNameTextBox:UITextBox;
var musicTextBox:UITextBox;
var bpmTextBox:UITextBox;
var playerXTextBox:UITextBox;
var playerYTextBox:UITextBox;
var maxJumpsTextBox:UITextBox;
var maxLevelWidth:UITextBox;
var aiLvl:UITextBox;
var song:UIFileExplorer;
var songPlayer:UIAudioPlayer;

// var songBytes:Bytes;
var background:FlxSprite;
var overlay:FlxSprite;
var onSave:Dynamic;

function create() {
	onSave = data.onSave;
	FlxG.state.persistentUpdate = false;
	FlxG.state.persistentDraw = true;

	overlay = new FlxSprite();
	overlay.makeGraphic(FlxG.width, FlxG.height, 0xAA000000);
	add(overlay);

	background = new FlxSprite(100, 70);
	background.makeGraphic(FlxG.width - 200, 500, 0xFF303030);
	add(background);

	var title = new UIText(background.x + 30, background.y + 30, background.width - 60, "Create New Level", 32);
	add(title);

	levelNameTextBox = new UITextBox(background.x + 30, background.y + 110, "Level", 200);
	add(levelNameTextBox);
	addLabelOn(levelNameTextBox, "Level Name");

	musicTextBox = new UITextBox(background.x + 300, background.y + 110, "field", 200);
	add(musicTextBox);
	addLabelOn(musicTextBox, "Music");

	song = new UIFileExplorer(background.x + 550, background.y + 110, null, null, 'ogg', function(path, res) {
		if (path == null || res == null)
			return;
		var songPlayer:UIAudioPlayer = new UIAudioPlayer(song.x + 8, song.y + 8, res);
		song.members.push(songPlayer);
		song.uiElement = songPlayer;
	});
	add(song);
	addLabelOn(song, "SONG");

	bpmTextBox = new UITextBox(background.x + 30, background.y + 200, "136", 200);
	add(bpmTextBox);
	addLabelOn(bpmTextBox, "BPM");

	playerXTextBox = new UITextBox(background.x + 30, background.y + 290, "0", 200);
	add(playerXTextBox);
	addLabelOn(playerXTextBox, "Player X");

	playerYTextBox = new UITextBox(background.x + 300, background.y + 290, "64", 200);
	add(playerYTextBox);
	addLabelOn(playerYTextBox, "Player Y");

	maxJumpsTextBox = new UITextBox(background.x + 300, background.y + 200, "1", 200);
	add(maxJumpsTextBox);
	addLabelOn(maxJumpsTextBox, "Max Jumps");

	maxLevelWidth = new UITextBox(background.x + 550, background.y + 200, "0", 200);
	add(maxLevelWidth);
	addLabelOn(maxLevelWidth, "Max level width (x<768 = default)");

	aiLvl = new UITextBox(background.x + 550, background.y + 290, "0", 200);
	add(aiLvl);
	addLabelOn(aiLvl, "AI Level (0 = off)");

	var saveButton = new UIButton(background.x + background.width - 280, background.y + background.height - 70, "Save", saveLevel, 125);

	add(saveButton);

	var closeButton = new UIButton(background.x + background.width - 140, background.y + background.height - 70, "Cancel", closeCreator, 125);

	closeButton.color = 0xFFFF0000;

	add(closeButton);
}

function saveLevel() {
	var name = levelNameTextBox.label.text;
	var music = musicTextBox.label.text;
	var bpm = Std.parseInt(bpmTextBox.label.text);
	var playerX = Std.parseInt(playerXTextBox.label.text);
	var playerY = Std.parseInt(playerYTextBox.label.text);
	var maxJumps = Std.parseInt(maxJumpsTextBox.label.text);
	var levelWidth = Std.parseInt(maxLevelWidth.label.text);
	var aiLvl = Std.parseInt(aiLvl.label.text);
	var songBytes = song.file;

	if (name == "Level")
		return;

	if (music == "")
		music = "field";

	if (Math.isNaN(bpm))
		bpm = 136;

	if (Math.isNaN(playerX))
		playerX = 0;

	if (Math.isNaN(playerY))
		playerY = 64;

	if (Math.isNaN(maxJumps))
		maxJumps = 1;

	if (levelWidth == "")
		levelWidth = 0;

	if (Math.isNaN(aiLvl))
		aiLvl = 0;

	#if sys
	CoolUtil.safeSaveFile(Paths.getAssetsRoot()
		+ "/data/levels/"
		+ name
		+ ".xml",
		'<!DOCTYPE jam-level>\n<level name="'
		+ name
		+ '" music="'
		+ music
		+ '" bpm="'
		+ bpm
		+ '" aiLvl="'
		+ aiLvl
		+ '" levelWidth="'
		+ levelWidth
		+ '">\n\t<player x="'
		+ playerX
		+ '" y="'
		+ playerY
		+ '" maxJumpAmount="'
		+ maxJumps
		+ '"/>\n\t<stages>\n\t\t<stage name="stage0"/>\n\t</stages>\n</level>');
	if (songBytes != null)
		File.saveBytes(Paths.getAssetsRoot() + '/music/' + music + '.ogg', songBytes);
	#end

	FlxG.state.persistentUpdate = true;
	onSave(name);
	closeCreator();
}

function closeCreator() {
	FlxG.state.persistentUpdate = true;
	close();
}

function addLabelOn(ui:UISprite, text:String):UIText {
	var text:UIText = new UIText(ui.x, ui.y - 24, 0, text);
	ui.members.push(text);
	return text;
}
