import flixel.util.FlxTypedSignal;
import flixel.util.FlxBaseSignal;

import flixel.util.FlxDestroyUtil;
import Reflect;

class FunkinSignal {
	/**
		Since `FlxSignal` just a Typedef to the abstract class `FlxBaseSignal`, we make a new instance of this instead of extending it.

		Also `FlxSignal` uses Macros to generate the infinite possible arguments in the callback, so we have to handle infinite parameters ourselves.
	**/
	private var _signal:FlxBaseSignal = new FlxBaseSignal();

	/**
		There is a slight issue with this class, and it's if you have a listener with more parameters when a `dispatch` is called, it will throw an error / crash the game.

		This will ensure that your Signal will only call the listeners with the exact length or more parameters are passed.
	**/
	public var REQUIRED_PARAMS:Int = 0;

	function new(?_required_params:Int = 0) {
		this.REQUIRED_PARAMS = _required_params;

		dispatch = Reflect.makeVarArgs((args) -> {
			if (args.length < REQUIRED_PARAMS) throw "Not enough arguments for `FunkinSignal.dispatch`";
			_signal.processingListeners = true; // keeping for the sake of keeping it exactly the same.

			// We loop through the handlers (i.e the listeners) and generate the infinite arguments passed by the `dispatch` function.
			for (handler in _signal.handlers) {
				Reflect.callMethod(this, handler.listener, args);
				if (handler.dispatchOnce) _signal.removeHandler(handler);
			}

			_signal.processingListeners = false; // ditto
			if (_signal.pendingRemove != null) {
				for (handler in _signal.pendingRemove) _signal.removeHandler(handler);
				if (_signal.pendingRemove.length > 0) _signal.pendingRemove = [];
			}
		});
	}
	public function dispatch():T {} // creating the valid function to be overriden in the constructor ^^^

	public function add(listener:T):Void { _signal.add(listener); }
	public function addOnce(listener:T):Void { _signal.addOnce(listener); }

	public function remove(listener:T):Void { _signal.remove(listener); }
	public function removeAll():Void { _signal.removeAll(); }
	
	public function destroy():Void {
		_signal.destroy();
		_signal = null; // we let the Garbage Collector handle this.
	}

	public function has(listener:T):Bool { return _signal.has(listener); }
}
