package ;

import ecx.Wire;
import ecx.scene2d.components.Transform;
import ecx.types.EntityVector;
import ecx.System;

class AllocationNoiseSystem extends System {

	public var createPerFrame:Int = 10000;

	var _temp:EntityVector;

	var _transform:Wire<Transform>;
	var _motion:Wire<Motion>;

	public function new() {}

	override function initialize() {
		_temp = new EntityVector(10000);
	}
	override function update() {
		for(i in 0..._temp.length) {
			world.delete(_temp.get(i));
		}

		_temp.reset();

		for(i in 0...createPerFrame) {
			var e = world.create();
			_transform.create(e);
			_motion.create(e);
			world.commit(e);
			_temp.place(e);
		}
	}
}
