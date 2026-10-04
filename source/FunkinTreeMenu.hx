/*
	Created by ItsLJcool, Please credit if you use this :)

!! WARNING !!
	Currently, there is a bug in hscript-improved that breaks Inheritance. You can only extend a Class ONCE before the 2nd extending breaks...
	So you need to be wary of this, and I'm too lazy to go in-depth on why this issue is happening, and a good fix so lol

	This has also NOT been tested on CodenameEngine v1.0.1 or below. This may only work on Experimental Builds.
!! WARNING !!

	I'll provide an example fix here.

	GitHub: https://github.com/ItsLJcool?tab=repositories
	Ko-fi: https://ko-fi.com/itsljcool
	Discord @itsljcool

	|# This Custom Class is from LJ's Utility Scripts from the CodenameEngine Discord Server. 	#|
	|#																							#|
	|# If you want to see the other scripts, you can check out the forum link from here: 		#|
	|# https://discord.com/channels/860561967383445535/1474246206061547664			 			#|
*/

import flixel.util.FlxArrayUtil;
import flixel.group.FlxTypedSpriteGroup;

/* This is a Custom Class that you need to ensure you have the right import path in `./source/`, otherwise this could cause errors. */
import FunkinSignal;

// Using my beloved 💞
using StringTools;

/*
	You can also override this class if you want to add custom Main Tree Behaviour.
*/
class FunkinTreeMenu extends FlxBasic {
	/* This is emitted when the TreeMenu is closed, meaning no more Menus are open. */
	public var onExit:FunkinSignal = new FunkinSignal();

	/* This is emitted when a new Menu is added to the TreeMenu. */
	public var onMenuAdded:FunkinSignal = new FunkinSignal(1);

	/* This is emitted when a Menu is closed. */
	public var onMenuClosed:FunkinSignal = new FunkinSignal(1);

	/*
		If we should calculate and start menu transitions.
		NOTE: When overriding this class, the transition will not finish immediately.
		You must call `super.finish_transition()` when you want to finish the transition.
	*/
	public var allow_transitions:Bool = false;

	/* This is the whole tree of the Menus. */
	private var tree(default, null):Array<BaseTreeMenuScreen> = [];
	private var tree_length(default, null):Int = 0;

	/* This is all the current previous Menus. */
	private var previous_menus:Array<BaseTreeMenuScreen> = [];

	/* Internal variable to ensure... something? idfk who made this lmao */
	private var __treeCreated:Bool = false;

	override public function new() {
		super();

		__treeCreated = true;
	}

	override public function update(elapsed:Float) {
		var i:Int = 0;
		var menu:BaseTreeMenuScreen = null;
		while (i < tree_length) {
			if ((menu = tree[i++]) == null || !menu.active || !menu.exists) continue;

			if (i == tree_length || menu.transitioning) menu.update(elapsed);
		}

		i = previous_menus.length;
		while (i-- > 0) {
			if ((menu = previous_menus[i]).transitioning) menu.update(elapsed);
			else {
				menu.destroy();
				FlxArrayUtil.swapAndPop(previous_menus, i);
			}
		}

		if (in_transition) transition_update(elapsed);
	}

	override public function draw() {
		var i:Int = 0;
		var menu:BaseTreeMenuScreen = null;
		while (i < tree_length) {
			if ((menu = tree[i++]) == null || !menu.active || !menu.exists) continue;

			if (i == tree_length || menu.transitioning) menu.draw();
		}

		i = previous_menus.length;
		while (i-- > 0) if (previous_menus[i] != null) previous_menus[i].draw();
	}

	public function addMenu(menu:BaseTreeMenuScreen):BaseTreeMenuScreen {
		if (menu == null) return null;
		if (tree.indexOf(menu) != -1) return menu;

		tree.push(menu);
		if (!__treeCreated) return menu;

		menu.parent = this;
		tree_length++;

		onMenuAdded.dispatch(menu);
		menu.onOpen.dispatch();
		
		destroyPreviousMenus();
		menuChanged();
		return menu;
	}

	public function insertMenu(index:Int, menu:BaseTreeMenuScreen):BaseTreeMenuScreen {
		if (menu == null) return null;
		if (tree.indexOf(menu) != -1) return menu;

		if (index < 0) index = tree_length - ((-index - 1) % tree_length);

		tree.insert(index, menu);
		if (!__treeCreated) return menu;

		menu.parent = this;
		onMenuAdded.dispatch(menu);
		menu.onOpen.dispatch();

		if (index >= tree_length++) {
			destroyPreviousMenus();
			menuChanged();
		}

		return menu;
	}
	
	public function popMenu():BaseTreeMenuScreen
		return removeMenuPosition(tree_length - 1);

	public function removeMenu(menu:BaseTreeMenuScreen):BaseTreeMenuScreen
		return (menu == null) ? null : removeMenuPosition(tree.indexOf(menu));
	
	public function removeMenuPosition(index:Int):BaseTreeMenuScreen {
		if (index < 0 || index >= tree_length || tree_length == 0) return null;

		tree[index] = tree[tree.length - 1];

		var menu = tree.pop();
		menu.onClose.dispatch();
		menu.parent = null;

		if (!__treeCreated) return menu;

		previous_menus.push(menu);
		
		onMenuClosed.dispatch(menu);
		if (index == --tree_length) menuChanged();

		return menu;
	}

	private var in_transition(default, set):Bool = false;
	private function set_in_transition(value:Bool):Bool {
		in_transition = value;
		for (menu in tree) if (menu != null) menu.transitioning = in_transition;
		for (menu in previous_menus) if (menu != null) menu.transitioning = in_transition;
		return in_transition;
	}

	/* Called before the transition starts. */
	private function pre_transition() { }
	/* This is called when the transition starts. */
	private function start_transition() { in_transition = true; }

	/*
		This is how we handle custom transitions.
		When overriding this class, you call `super.finish_transition()` when you want to finish the transition.
	*/
	private function finish_transition(?isOut:Bool = false) { in_transition = false; }

	/*
		This function is called every frame when `in_transition` is true.
		This will allow for updating group positions smoothly on multiple frames rather than just 1 function call.
		Same goes here, if you want to stop the str
	*/
	private function transition_update(elapsed:Float) { }

	private function menuChanged() {
		if (tree_length == 0) exit();
		else if (allow_transitions) {
			pre_transition();
			start_transition();
		}

	}

	public function destroyPreviousMenus() {
		for (menu in previous_menus) menu.destroy();
		CoolUtil.clear(previous_menus);
	}

	public function exit() {
		onExit.dispatch();
	}

	override public function destroy() {
		super.destroy();
		destroyPreviousMenus();
	}
}

/*
	This is a Class you can override yourself, and do whatever.
	It's like a Godot Node, but for the `FunkinTreeMenu` system.

	Extending it is best, if you want to add custom behaviour to the menu.
*/
class BaseTreeMenuScreen extends FlxBasic {

	public var transitioning:Bool = false;

    public var onClose:FunkinSignal = new FunkinSignal();
	public var onOpen:FunkinSignal = new FunkinSignal();

	public var parent:FunkinTreeMenu;
	override public function new() { super(); }

    public function close() {
        onClose.dispatch();

        if (parent == null) return destroy();
        else parent.removeMenu(this);
    }

    override public function update(elapsed:Float) { }
    override public function draw() { }

    override public function destroy() {
		onClose.destroy();
		onOpen.destroy();
		super.destroy();
	}
}

/*
	This is an Example Class override for `BaseTreeMenuScreen`.
	I wouldn't use this class exactly but it's an example on how you can override `BaseTreeMenuScreen` properly with the Inheritance bug.
*/
/*
class InheritanceFixExample extends BaseTreeMenuScreen {
    public var group:FlxTypedSpriteGroup;

    override public function new() {
        super();

        group = new FlxTypedSpriteGroup();
        group.camera = this.camera;
    }

    override public function update(elapsed:Float) { _update_fix(elapsed); }

	// This is the Inheritance fix. Since you can apparently only override functions once per Custom Class Inheritance. Fix for now
	// Any class that overrides this `InheritanceFixExample` needs to override THIS function, as you won't be bale to override the `update` function 💔
	private function _update_fix(elapsed:Float) {
        group.camera = this.camera;
		if (!visible || !active) return;
		group.update(elapsed);
	}

    override public function draw() { _draw_fix(); }
	private function _draw_fix() {
		if (!visible || !exists) return;
		group.draw();
	}

    override public function destroy() { _destroy_fix(); }
	private function _destroy_fix() {
		group.destroy();
		super.destroy();
	}
}
*/