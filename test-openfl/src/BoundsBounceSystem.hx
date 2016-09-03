package ;

import flash.Lib;
import ecx.Wire;
import ecx.scene2d.components.Transform;
import ecx.Family;
import ecx.System;

class BoundsBounceSystem extends System {

	var _entities:Family<Transform, Motion>;
	var _transform:Wire<Transform>;
	var _motion:Wire<Motion>;
	var _collisionRadius:Wire<CollisionRadius>;

	public function new() {}

	override function update() {
		var left = 0;
		var top = 0;
		var right = Lib.current.stage.stageWidth;
		var bottom = Lib.current.stage.stageHeight;
		for(entity in _entities) {
			var motion = _motion.get(entity);
			var x = _transform.getX(entity);
			var y = _transform.getY(entity);
			var radius = _collisionRadius.get(entity);

			if(x - radius <= left && motion.vx <= 0) {
				_transform.setX(entity, left + radius);
				motion.vx = -motion.vx;
			}
			else if(x + radius >= right && motion.vx >= 0) {
				_transform.setX(entity, right - radius);
				motion.vx = -motion.vx;
			}

			if(y - radius <= top && motion.vy <= 0) {
				_transform.setY(entity, top + radius);
				motion.vy = -motion.vy;
			}
			else if(y + radius >= bottom && motion.vy >= 0) {
				_transform.setY(entity, bottom - radius);
				motion.vy = -motion.vy;
			}
		}
	}
}
