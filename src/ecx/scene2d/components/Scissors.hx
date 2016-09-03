package ecx.scene2d.components;

import hotmem.F32;
import ecx.ds.CBitArray;
import hotmem.F32Array;

class Scissors extends Service implements IComponent {

	var _x:F32Array;
	var _y:F32Array;
	var _width:F32Array;
	var _height:F32Array;

	var _mask:CBitArray;

	public function new() {}

	override function __allocate() {
		var capacity = world.capacity;
		_x = new F32Array(capacity);
		_y = new F32Array(capacity);
		_width = new F32Array(capacity);
		_height = new F32Array(capacity);
		_mask = new CBitArray(capacity);
	}

	inline public function create(entity:Entity):Bool {
		_mask.enable(entity.id);
		_x[entity.id] = 0;
		_y[entity.id] = 0;
		_width[entity.id] = 0;
		_height[entity.id] = 0;
		return true;
	}

	inline public function get(entity:Entity):Bool {
		return _mask.get(entity.id);
	}

	inline public function set(entity:Entity, mock:Bool) {}

	inline public function remove(entity:Entity) {
		_mask.disable(entity.id);
	}

	inline public function has(entity:Entity):Bool {
		return _mask.get(entity.id);
	}

	inline public function copy(source:Entity, destination:Entity) {
		_mask.enable(destination.id);
		_x[destination.id] = _x[source.id];
		_y[destination.id] = _y[source.id];
		_width[destination.id] = _width[source.id];
		_height[destination.id] = _height[source.id];
	}

//	@:access(jam.scene.Transform)
//	public function getWorldClip(entity:Entity, transform:Transform):Rectangle {
//		var rc = rect;
//		var a = tr._wa;
//		var d = tr._wd;
//		var x = tr._wx;
//		var y = tr._wy;
//		var worldRect = _worldRect;
//		worldRect.x = rc.x * a + x;
//		worldRect.y = rc.y * d + y;
//		worldRect.width = MathEx.fabs(rc.width * a);
//		worldRect.height = MathEx.fabs(rc.height * d);
//		return worldRect;
//	}

	public function contains(entity:Entity, x:Float, y:Float):Bool {
		x -= _x[entity.id];
		var size = _width[entity.id];
		if (size >= 0) {
			if (x < 0 || x > size) {
				return false;
			}
		}
		else if (x > 0 || x < size) {
			return false;
		}

		y -= _y[entity.id];
		var size = _height[entity.id];
		if (size >= 0) {
			if (y < 0 || y > size) {
				return false;
			}
		}
		else if (y > 0 || y < size) {
			return false;
		}

		return true;
	}
}


class ScissorsRect {
	public var x:F32 = 0;
	public var y:F32 = 0;
	public var width:F32 = 0;
	public var height:F32 = 0;

	public function new() {}
}