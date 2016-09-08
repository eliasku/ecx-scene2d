package ;

import ecx.common.systems.SystemRunner;
import flash.events.Event;
import ecx.World;
import flash.Lib;
import ecx.Engine;
import ecx.scene2d.Scene2d;
import ecx.WorldConfig;
import flash.display.Sprite;

class Main extends Sprite {

	var _world:World;

	public function new() {
		super();

		var config = new WorldConfig();

		config.include(new Scene2d());

		// general
		config.add(new Stats());

		// systems
		config.add(new Scene());
		config.add(new AllocationNoiseSystem(), -1);
		config.add(new OpenflTest());
		config.add(new MotionSystem(), 1);
		config.add(new BoundsBounceSystem(), 2);
//		config.add(new DisplaySystem(), Scene2d.PRIORITY_INVALIDATE + 100);

		// traversing benchmark test
		//config.add(new TraverseSystem());

		// components
		config.add(new Display());
		config.add(new Motion());
		config.add(new CollisionRadius());

		_world = Engine.createWorld(config, 1100000);

		Lib.current.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
	}

	function onEnterFrame(_) {
		_world.resolve(SystemRunner).updateFrame();
	}

	public static function main() {
		var main = new Main();
	}
}
