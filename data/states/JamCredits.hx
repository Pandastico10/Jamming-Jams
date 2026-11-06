import funkin.editors.ui.UISliceSprite;
import openfl.display.BlendMode;
import flixel.addons.display.FlxBackdrop;
import flixel.text.FlxText.FlxTextBorderStyle;


var boxes:FlxGroup = new FlxGroup();
var blur = new CustomShader('blur');
var scanline = new CustomShader('scanline');
var creditLinks:Array<Dynamic> = [];
var texts:FlxGroup = new FlxGroup();
var icons:FlxGroup = new FlxGroup();
var desc:FlxGroup = new FlxGroup();
var bg = new FlxSprite();
var vignette = new FlxSprite();
var temp:Float = 0.25;
var delay:Float = 0.10;

function create() {
	CoolUtil.playMenuSong();
	FlxG.mouse.visible = true;

	bg = new FlxBackdrop(Paths.image('game/square'), FlxAxes.XY, 0, 0);
	bg.setGraphicSize(FlxG.width, FlxG.height);
	bg.velocity.set(-30, 7.5);
	bg.alpha = 0.35;
	// bg.blend = BlendMode.MULTIPLY;
	add(bg);
	bg.cameras = [camera];
	bg.screenCenter();
	bg.color = 0xFFea76cd;

	if (FlxG.save.data.shaders) {
		bg.shader = blur;
	}

	vignette = new FlxSprite().loadGraphic(Paths.image("game/vignette"));
	vignette.setGraphicSize(FlxG.width, FlxG.height);
	vignette.screenCenter();
	add(vignette);

	setup();
	for (i in boxes) {
		i.alpha = 0;
		var targetY = i.y;
		i.y = FlxG.height + 50;
		FlxTween.tween(i, {y: targetY, alpha: 1}, 1, {
			ease: FlxEase.cubeOut,
			startDelay: temp
		});
		temp += delay;
	}
	for (i in texts) {
		i.alpha = 0;
		FlxTween.tween(i, {alpha: 1}, 1, {
			ease: FlxEase.cubeOut,
			startDelay: temp
		});
		temp += delay;
	};
	for (i in icons) {
		i.alpha = 0;
		FlxTween.tween(i, {alpha: 1}, 1, {
			ease: FlxEase.cubeOut,
			startDelay: temp
		});
		temp += delay;
	};
	for (i in desc) {
		i.alpha = 0;
		FlxTween.tween(i, {alpha: 1}, 1, {
			ease: FlxEase.cubeOut,
			startDelay: temp
		});
		temp += delay;
	};

	// apparently this is important????
	// for (boxx in boxes) {
	// 	// boxx.incorporeal = true;
	// 	for (frame => name in ["normal", "hover", "pressed"])
	// 		boxx.animation.add(name, [frame], 0, false);
	// }
}

function update(elapsed:Float) {
	FlxG.camera.zoom = CoolUtil.fpsLerp(FlxG.camera.zoom, 1, 0.1);
	for (box in boxes) {
		box.framesOffset = box.hovered ? 9 : 0;
	}
	if (FlxG.mouse.justPressed) {
		for (link in creditLinks) {
			if (FlxG.mouse.overlaps(link.sprite)) {
				CoolUtil.openURL(link.url);
				break;
			}
		}
	}

	if (controls.BACK)
		FlxG.switchState(new MainMenuState());
}

function measureHit(curMeasure:Int) {
	FlxG.camera.zoom += 0.03;
}

function setup() {
	var topBox = new UISliceSprite(12, 12, FlxG.width - 24, 64, "button");
	add(topBox);
	boxes.add(topBox);

	var musicBox = new UISliceSprite(topBox.x, topBox.y + topBox.bHeight + 12, (FlxG.width / 3) * 2 - 12, 384, "button");
	add(musicBox);
	boxes.add(musicBox);

	var directBox = new UISliceSprite(musicBox.x + musicBox.bWidth + 12, topBox.y + topBox.bHeight + 12, FlxG.width / 3 - 24, 384, "button");
	add(directBox);
	boxes.add(directBox);

	var specialBox = new UISliceSprite(12, musicBox.y + musicBox.bHeight + 12, FlxG.width - 24, 256, "button");
	add(specialBox);
	boxes.add(specialBox);

	var back = new FlxText(24, 12, FlxG.width, "Credits");
	JamUtils.setupText(back, 64, 'left', "outline.ttf");
	add(back);
	texts.add(back);

	var credits = new FlxText(-12, 12, FlxG.width, "Jamming-Jams");
	JamUtils.setupText(credits, 64, "right", "outline.ttf");
	add(credits);
	texts.add(credits);

	var music = new FlxText(topBox.x + 12 + topBox.bWidth / 4, musicBox.y + musicBox.bHeight / 2, FlxG.width, "Music");
	JamUtils.setupText(music, 64, "left", "outline.ttf");
	music.y -= music.height / 2;
	add(music);
	texts.add(music);

	var direct = new FlxText(directBox.x + 48, directBox.y, FlxG.width, "Coding");
	JamUtils.setupText(direct, 64, "left", "outline.ttf");
	add(direct);
	texts.add(direct);

	var special = new FlxText(specialBox.x + 12, specialBox.y, FlxG.width, "Special Thanks");
	JamUtils.setupText(special, 64, "center", "outline.ttf");
	add(special);
	texts.add(special);

	var line1 = new FlxSprite(music.x + 96, musicBox.y + 12).makeGraphic(6, musicBox.bHeight / 2 - 48, 0xFFFFFFFF);
	add(line1);
	icons.add(line1);

	var line2 = new FlxSprite(music.x + 96, musicBox.y + 256 - 36).makeGraphic(6, musicBox.bHeight / 2 - 48, 0xFFFFFFFF);
	add(line2);
	icons.add(line2);

	var line3 = new FlxSprite(special.x + 128 * 4, special.y + 128 - 36).makeGraphic(6, musicBox.bHeight / 2 - 48, 0xFFFFFFFF);
	add(line3);
	icons.add(line3);

	var sandbag = new FlxText(musicBox.x + 24 + 128, musicBox.y + 12, FlxG.width,
		"(Quarter Circle)\nMade the song used in level 1\nAlso helped direct another\nmod where i started coding");
	JamUtils.setupText(sandbag, 22, "left", "small.otf");
	add(sandbag);
	desc.add(sandbag);

	var sebas = new FlxText(musicBox.x + 24 + 348, musicBox.y + 12, FlxG.width, "(Lady's Locker Room)\nMade the mashup\nused in level 2");
	JamUtils.setupText(sebas, 22, "left", "small.otf");
	add(sebas);
	desc.add(sebas);

	var gueta = new FlxText(musicBox.x + 24 + 128, musicBox.y + musicBox.bHeight - 60 - 80, FlxG.width, "(Dj's Mix)\nMade the mashup\nused in level 3");
	JamUtils.setupText(gueta, 22, "left", "small.otf");
	add(gueta);
	desc.add(gueta);

	var indrax = new FlxText(musicBox.x + 24 + 348, musicBox.y + musicBox.bHeight - 60 - 80, FlxG.width, "(Perreo Heart)\nMade the mashup\nused in level 4");
	JamUtils.setupText(indrax, 22, "left", "small.otf");
	add(indrax);
	desc.add(indrax);

	var panda = new FlxText(directBox.x + 12, directBox.y + 96 + 48 + 12, FlxG.width,
		"Made basically everything else\nthe coding, directed the mod and\nmade the levels and main menu song\nalong with the cabin skin and\nmonster graphics\nyou can check out my devlog\ninside the mod folder");
	JamUtils.setupText(panda, 24, "left", "small.otf");
	add(panda);
	desc.add(panda);

	var disc = new FlxText(specialBox.x + 24 + 128, specialBox.y + 48, FlxG.width,
		"All members in the Codename Engine Discord Server\nHelped with getting answers for problems i had\nduring development\nitsLJcool: FunkinTypeText Class, save data\nCare: global 4:3 script\nGeng-Yan: Transition script\nCodename Api writters");
	JamUtils.setupText(disc, 22, "left", "small.otf");
	add(disc);
	desc.add(disc);

	var other = new FlxText(line3.x + 24, specialBox.y + 48, FlxG.width,
		"Vsc Server (General support and great friend group),\nZakopilled <3 (Did the menu sprites),\nRos24 (Feedback and coding help),\nEliza729 (Emotional support),\nSing for the sky team (Being awesome and also swag),\nAnd of course, You!");
	JamUtils.setupText(other, 24, "left", "small.otf");
	add(other);
	desc.add(other);

	addCreditIcon(musicBox.x + 12, musicBox.y + 12, "https://www.youtube.com/@Sandbag40", "sandbag");
	addCreditIcon(musicBox.x + musicBox.bWidth - 60 - 80, musicBox.y + 12, "https://soundcloud.com/sebaswow-2", "sebas");
	addCreditIcon(musicBox.x + 12, musicBox.y + musicBox.bHeight - 60 - 80, "https://on.soundcloud.com/OF1NHhHLasBC15Riw6", "gueta");
	addCreditIcon(musicBox.x + musicBox.bWidth - 60 - 80, musicBox.y + musicBox.bHeight - 60 - 80, "https://soundcloud.com/indrax-913629251", "indrax");
	addCreditIcon(directBox.x + 96, directBox.y + 48, "https://www.youtube.com/@PandaMashups", "panda");
	addCreditIcon(specialBox.x + 12, specialBox.y + 96, "https://discord.gg/codename-crew", "codename");
}

function addCreditIcon(x:Float, y:Float, url:String, name:String) {
	var icon = new FlxSprite(x, y).loadGraphic(Paths.image('credits/' + name));
	icon.setGraphicSize(128, 128);
	icon.updateHitbox();
	add(icon);
	icons.add(icon);

	creditLinks.push({sprite: icon, url: url});
}
