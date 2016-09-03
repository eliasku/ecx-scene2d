package ;

import ecx.Family;
import ecx.System;
import ecx.Wire;
import ecx.scene2d.components.Transform;
import ecx.utility.systems.TimeSystem;

class MotionSystem extends System {

	var _entities:Family<Transform, Motion>;

	var _time:Wire<TimeSystem>;
	var _transform:Wire<Transform>;
	var _motion:Wire<Motion>;

	public function new() {}

	override function update() {
		var dt = _time.deltaTime;
		for(entity in _entities) {
			var motion = _motion.get(entity);
			var x = _transform.getX(entity);
			var y = _transform.getY(entity);
			motion.vx += dt * motion.ax;
			motion.vy += dt * motion.ay;
			x += dt * motion.vx;
			y += dt * motion.vy;
			_transform.position(entity, x, y);
		}
	}
}
