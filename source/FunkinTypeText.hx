/**
	Created by ItsLJcool, Please credit if you use this :)

	GitHub: https://github.com/ItsLJcool?tab=repositories
	Ko-fi: https://ko-fi.com/itsljcool
	Discord @itsljcool

	Code Changes by Pandastico
	Made to behave more like a DialogueManager than a TypeText
	Huge thanks to ItsLJcool for making it public!

**/

import FunkinSignal;
import openfl.text.TextFormat;
import flixel.text.FlxText;
import flixel.addons.text.FlxTypeText;
import flixel.addons.text.FlxTypeText.TypeSound;

class FunkinTypeText extends FlxText {
	/**
		The string that will be displayed before the text.
	**/
	public var prefix:String = "";

	// Siganl that is dispatched when the text has started typing the first character.
	public var onStart:FunkinSignal = new FunkinSignal();

	// Signal that is dispatched when new text is generated.
	public var onProgress:FunkinSignal = new FunkinSignal();

	/**
		Signal that is dispatched when the text has finished typing.
		This is dispatched when the whole typing is finished, this will not call during a List reading until it's fully complete. Use `onNextList` for that.
	**/
	public var onComplete:FunkinSignal = new FunkinSignal();

	// Signal that is dispatched when the next list item has been parsed.
	public var onNextList:FunkinSignal = new FunkinSignal();

	// Signal that is called if the json contains a Call.
	public var onCall:FunkinSignal = new FunkinSignal();
	public var call:String = "";

	// Internal tracking variable to dispatch the `onStart` signal.
	private var _has_started:Bool = false;

	public var index:String = "0447";
	public var emotion:String = "Normal";

	public var isTyping:Bool = false;
	public var isPaused:Bool = false;

	public var waitForInput:Bool = false;
	private var waiting_for_next:Bool = false;

	public function continueDialogue() {
		if (!waitForInput)
			return;
		if (call != null && call != "")
			onCall.dispatch(call);
		next_list_item();
	}

	// Allows for delaying the typing of pause characters, defined in `pause_characters`.
	public var allow_pause_characters:Bool = true;
	// If the next displaying text is apart of this array, we change the delay to our `pause_delay`.
	public var pause_characters:Array<String> = [",", "."];

	// The delay between each character.
	public var delay:Float = 0.05;
	// The delay between pausing characters.
	public var pause_delay:Float = 0.2;

	// The current string the text is displaying.
	private var display_text:String = "";

	// The actual text that will be displayed when finished.
	private var final_text:String = "";

	// internal tracking timer for typing the next character.
	private var _timer:Float = 0;

	private var text_length(default, set):Int = 0;

	private function set_text_length(value:Int):Int {
		return this.text_length = Std.int(FlxMath.bound(value, 0, this.final_text.length));
	}

	// An array of information to type out. Deletes the first index when reading a new line.
	private var reading_list:Array<TypeTextItem> = [];

	// quick check if we can shift the list without getting a null object.
	private var can_shift_list(get, never):Bool;

	private function get_can_shift_list():Bool {
		return reading_list.length > 0;
	}

	// Sound stuff
	// An array of sounds to randomly choose from when typing.
	public var sounds:Array<FlxSound> = [];

	// If a new character is being typed and we play a sound, should it force the sound to repeat if playing?
	public var finish_sounds:Bool = false;

	/**
		If `true`, the default sound will be used instead of the `sounds` array.
		This is just re-implemented from `FxTypeText` so you can use the default sound if needed.
	**/
	public var use_default_sound:Bool = false;

	private var _default_sound:FlxSound = FlxG.sound.load(new TypeSound());

	// If `true`, the pitch of the sound will be randomized. Using the `sound_pitch_random` value.
	public var randomize_pitch:Bool = false;
	public var next_delay:Float = 2.5;

	/**
		The randomized pitch of the sound
		X = min, Y = max
	**/
	public var sound_pitch_random:FlxPoint = FlxPoint.get(0.9, 1.1);

	/**
		Changes the pitch of the sounds, does nothing if `randomize_pitch` is true.
	**/
	public var sound_pitch(default, set):Float = 1;

	private function set_sound_pitch(value:Float):Float {
		if (use_default_sound)
			_default_sound.pitch = sound_pitch;
		for (sound in sounds)
			sound.pitch = sound_pitch;
		sound_pitch = value;
		return value;
	}

	/**
		Sets the volume of every sound in 1 variable.
		Returns itself instead of the first sound in the array, so reading from this might be false in specific cases.
	**/
	public var SOUND_VOLUME(default, set):Float = 1;

	private function set_SOUND_VOLUME(value:Float):Float {
		SOUND_VOLUME = FlxMath.bound(value, 0, 1);
		if (use_default_sound)
			_default_sound.volume = SOUND_VOLUME;
		for (sound in sounds)
			sound.volume = SOUND_VOLUME;
		return SOUND_VOLUME;
	}

	public function new(?_x:Float = 0, ?_y:Float = 0, ?_fieldWidth:Float = 0, ?_size:Int = 8, ?_embeddedFont:Bool = true) {
		super(_x, _y, _fieldWidth, "", _size, _embeddedFont);
		SOUND_VOLUME = 0.5;
	}

	/**
		@param new_text The new text to type out.
		@param new_delay The delay between each character.
	**/
	public function resetText(new_text:String, ?new_delay:Float = 0.05):Void {
		this.isTyping = this.isPaused = false;
		this.final_text = new_text;

		this.text = this.display_text = "";

		if (new_delay != null)
			this.delay = new_delay;

		this.text_length = 0;
	}

	/**
		@param _starting_delay The delay before the text starts typing.
	**/
	public function start(?_starting_delay:Float = 0):Void {
		waiting_for_next = false;
		_timer -= (_starting_delay ?? 0);

		has_skipped = false;
		isTyping = true;
	}

	private var has_skipped:Bool = false;

	public function skip():Void {
		text = display_text = prefix + final_text;
		text_length = final_text.length;
		onProgress.dispatch();
		if (has_skipped) {
			next_list_item();
			_timer = 0;
			return;
		}
		has_skipped = true;
	}

	public function pause():Void {
		isPaused = true;
	}

	public function resume():Void {
		isPaused = false;
	}

	/**
		@param new_list The list of `TypeTextItem` to read.
	**/
	public function resetList(new_list:Array<TypeTextItem>) {
		reading_list = new_list.filter((item) -> item is TypeTextItem);
		next_list_item();
	}

	private var stack_delay:Float = 0;

	private function next_list_item() {
		if (!can_shift_list)
			return;
		var item = reading_list.shift();

		if (item.waitForInput != null)
			waitForInput = item.waitForInput;

		if (item.delay != null)
			delay = item.delay;
		stack_delay = next_delay;

		if (item.allow_pause_characters != null)
			allow_pause_characters = item.allow_pause_characters;
		if (item.pausing_delay != null)
			pausing_delay = item.pausing_delay;

		if (item.new_prefix != null)
			prefix = item.new_prefix;

		if (item.randomize_pitch != null)
			randomize_pitch = item.randomize_pitch;
		if (item.sound_pitch_random != null) {
			sound_pitch_random.set(item.sound_pitch_random.x, item.sound_pitch_random.y);
			item.sound_pitch_random.put();
		}

		if (item.sound_pitch != null)
			sound_pitch = item.sound_pitch;

		if (item.finish_sounds != null)
			finish_sounds = item.finish_sounds;
		if (item.index != null)
			index = item.index;
		if (item.emotion != null)
			emotion = item.emotion;
		if (item.call != null)
			call = item.call;
		else
			call = "";

		if (item.additive) {
			final_text += item.text;
			_has_started = false;
		} else {
			resetText(item.text);
		}

		start(item.start_delay);
		onNextList.dispatch();
		onCall.dispatch(call);
	}

	private function play_sound() {
		_stopped_sound = false;
		if (sounds.length > 0 && !use_default_sound) {
			if (!finish_sounds)
				for (sound in sounds)
					sound.stop();

			var sound = FlxG.random.getObject(sounds);
			sound.pitch = sound_pitch;
			if (randomize_pitch)
				sound.pitch = FlxG.random.float(sound_pitch_random.x, sound_pitch_random.y);
			sound.play(!finish_sounds);
		} else if (use_default_sound) {
			if (randomize_pitch)
				_default_sound.pitch = FlxG.random.float(sound_pitch_random.x, sound_pitch_random.y);
			_default_sound.play(!finish_sounds);
		}
	}

	private var _stopped_sound:Bool = false;

	private function stop_sound() {
		if (_stopped_sound)
			return;
		if (use_default_sound)
			_default_sound.stop();
		else
			for (sound in sounds)
				sound.stop();
		_stopped_sound = true;
	}

	override public function update(elapsed:Float):Void {
		if (isTyping) {
			if (!isPaused && text_length < final_text.length)
				_timer += elapsed;

			if (_timer >= delay) {
				text_length += Std.int(_timer / delay);

				// we should only substr if we should update the length ya'know?
				display_text = prefix + final_text.substr(0, text_length);

				// not sure why we do this, but `FlxTypeText` does it so it must be for a very specific reason.
				_timer %= delay;

				if (!_has_started) {
					_has_started = true;
					onStart.dispatch();
				}
				play_sound();
			}
		}

		if (text != display_text) {
			text = display_text;

			onProgress.dispatch();

			if (allow_pause_characters && _timer >= 0 && pause_characters.contains(final_text.charAt(text_length - 1)))
				_timer -= pause_delay;
		}

		if (text_length >= final_text.length && !isPaused && isTyping) {
			isTyping = false;

			if (!can_shift_list) {
				complete();
			} else if (!waitForInput) {
				waiting_for_next = true;
			}

			stop_sound();
		}

		if (waiting_for_next && !isPaused && !waitForInput) {
			stack_delay -= elapsed;

			if (stack_delay <= 0) {
				waiting_for_next = false;
				next_list_item();
			}
		}

		super.update(elapsed);
	}

	private function complete() {
		isTyping = false;
		_timer = 0;

		onComplete.dispatch();
	}
}

class TypeTextItem {
	// Anything that is `null` will not override the default value.
	// Any initalized values are required.
	public var text:String = "";
	public var new_prefix:String;

	public var delay:Float;
	public var start_delay:Float = 0;
	public var next_delay:Float = 1;

	public var allow_pause_characters:Bool;
	public var pausing_delay:Float;

	public var sound_pitch:Float;

	public var randomize_pitch:Bool;
	public var sound_pitch_random:FlxPoint;

	public var finish_sounds:Bool;

	// If this should be appeneded to the previous text.
	public var additive:Bool = false;

	// shit added for the icon loading
	public var index:String = "0447";
	public var emotion:String = "Normal";

	public var waitForInput:Bool = false;

	public var call:String = '';

	public function new(_text:String, ?_delay:Float, ?_start_delay:Float, ?_next_delay:Float, ?_additive:Bool, ?_new_prefix:String) {
		this.text = _text;
		if (_new_prefix != null)
			this.new_prefix = _new_prefix;

		if (_delay != null)
			this.delay = _delay;
		if (_start_delay != null)
			this.start_delay = _start_delay;

		this.next_delay = (_next_delay ?? 1);
		this.additive = (_additive ?? false);
	}

	public function setText(_text:String):TypeTextItem {
		this.text = _text;
		return this;
	}

	public function setNewPrefix(_new_prefix:String):TypeTextItem {
		this.new_prefix = _new_prefix;
		return this;
	}

	public function setDelay(_delay:Float):TypeTextItem {
		this.delay = _delay;
		return this;
	}

	public function setStartDelay(_start_delay:Float):TypeTextItem {
		this.start_delay = _start_delay;
		return this;
	}

	public function setNextDelay(_next_delay:Float):TypeTextItem {
		this.next_delay = _next_delay;
		return this;
	}

	public function setAllowPausingCharacters(_allow_pause_characters:Bool):TypeTextItem {
		this.allow_pause_characters = _allow_pause_characters;
		return this;
	}

	public function setPausingDelay(_pausing_delay:Float):TypeTextItem {
		this.pausing_delay = _pausing_delay;
		return this;
	}

	public function setAdditive(_additive:Bool):TypeTextItem {
		this.additive = _additive;
		return this;
	}

	public function setSoundPitch(_sound_pitch:Float):TypeTextItem {
		this.sound_pitch = _sound_pitch;
		return this;
	}

	public function setRandomizePitch(_randomize_pitch:Bool):TypeTextItem {
		this.randomize_pitch = _randomize_pitch;
		return this;
	}

	public function setSoundPitchRandom(min:Float, max:Float):TypeTextItem {
		this.sound_pitch_random.set(min, max);
		return this;
	}

	public function setFinishSounds(_finish_sounds:Bool):TypeTextItem {
		this.finish_sounds = _finish_sounds;
		return this;
	}

	public function setIndex(_index:String):TypeTextItem {
		this.index = _index;
		return this;
	}

	public function setEmotion(_emotion:String):TypeTextItem {
		this.emotion = _emotion;
		return this;
	}

	public function setWaitForInput(_waitForInput:Bool):TypeTextItem {
		this.waitForInput = _waitForInput;
		return this;
	}

	public function setCall(_call:String):TypeTextItem {
		this.call = _call;
		return this;
	}

	/**
		Creates a new `TypeTextItem` from a json object.
		Useful for saving and exporting arrays of these if needed.
	**/
	public static function fromJson(data:Dynamic):TypeTextItem {
		return new TypeTextItem(data).setText(data.text)
			.setNewPrefix(data.new_prefix)
			.setDelay(data.delay)
			.setStartDelay(data.start_delay)
			.setNextDelay(data.next_delay)
			.setAllowPausingCharacters(data.allow_pause_characters)
			.setPausingDelay(data.pausing_delay)
			.setAdditive(data.additive)
			.setSoundPitch(data.sound_pitch)
			.setRandomizePitch(data.randomize_pitch) // .setSoundPitchRandom(data.sound_pitch_random.x, data.sound_pitch_random.y)
			.setFinishSounds(data.finish_sounds)
			.setIndex(data.index)
			.setEmotion(data.emotion)
			.setWaitForInput(data.waitForInput)
			.setCall(data.call);
	}

	/**
		Creates a json object from this `TypeTextItem`.
	**/
	public function toJson():Dynamic {
		var _data:Dynamic = {text: text, next_delay: next_delay, additive: additive};
		if (new_prefix != null)
			_data.new_prefix = new_prefix;
		if (delay != null)
			_data.delay = delay;
		if (start_delay != null)
			_data.start_delay = start_delay;
		if (allow_pause_characters != null)
			_data.allow_pause_characters = allow_pause_characters;
		if (pausing_delay != null)
			_data.pausing_delay = pausing_delay;
		if (sound_pitch != null)
			_data.sound_pitch = sound_pitch;
		if (randomize_pitch != null)
			_data.randomize_pitch = randomize_pitch;
		if (sound_pitch_random != null)
			_data.sound_pitch_random = {x: sound_pitch_random.x, y: sound_pitch_random.y};
		if (finish_sounds != null)
			_data.finish_sounds = finish_sounds;
		return _data;
	}
}
