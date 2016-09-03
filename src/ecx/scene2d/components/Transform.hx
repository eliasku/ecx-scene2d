package ecx.scene2d.components;

import hotmem.F32Array;
import hotmem.F32;
import ecx.types.EntityVector;
import ecx.ds.CBitArray;

class Transform extends Service implements IComponent {

	inline static var PI:Float = 3.14159265359;
	inline static var TO_RAD:Float = PI / 180.0;

	inline public function setX(entity:Entity, x:F32) {
		_x[entity.id] = x;
		markDirty(entity);
	}

	inline public function setY(entity:Entity, y:F32) {
		_y[entity.id] = y;
		markDirty(entity);
	}

	inline public function getX(entity:Entity):F32 {
		return _x[entity.id];
	}

	inline public function getY(entity:Entity):F32 {
		return _y[entity.id];
	}

	inline public function position(entity:Entity, x:F32, y:F32) {
		_x[entity.id] = x;
		_y[entity.id] = y;
		markDirty(entity);
	}

	inline public function scale(entity:Entity, scaleX:F32, scaleY:F32) {
		_scaleX[entity.id] = scaleX;
		_scaleY[entity.id] = scaleY;
		markDirty(entity);
		rebuildLocalMatrix(entity);
	}

	inline public function getRotation(entity:Entity, rotationDegrees:F32) {
		return _rotation[entity.id];
	}

	inline public function setRotation(entity:Entity, rotationDegrees:F32) {
		_rotation[entity.id] = rotationDegrees;
		markDirty(entity);
		rebuildLocalMatrix(entity);
	}

	inline public function resetDirty(entity:Entity) {
		return _dirtyMask.disable(entity.id);
	}

	inline public function isDirty(entity:Entity):Bool {
		return _dirtyMask.get(entity.id);
	}

	function rebuildLocalMatrix(entity:Entity) {
		var rads = _rotation[entity.id] * TO_RAD;
		var sin = Math.sin(rads);
		var cos = Math.cos(rads);
		var scaleX = _scaleX[entity.id];
		var scaleY = _scaleY[entity.id];
		_a[entity.id] = cos * scaleX;
		_b[entity.id] = sin * scaleX;
		_c[entity.id] = -sin * scaleY;
		_d[entity.id] = cos * scaleY;
	}

	/** Component Storage **/

	var _wa:F32Array;
	var _wb:F32Array;
	var _wc:F32Array;
	var _wd:F32Array;
	var _wy:F32Array;
	var _wx:F32Array;

	var _a:F32Array;
	var _b:F32Array;
	var _c:F32Array;
	var _d:F32Array;
	var _y:F32Array;
	var _x:F32Array;

	var _rotation:F32Array;
	var _scaleX:F32Array;
	var _scaleY:F32Array;

	var _mask:CBitArray;

	var _dirtyMask:CBitArray;
	var _dirtyVector:EntityVector;

	public function new() {}

	override function __allocate() {
		var capacity = world.capacity;
		_wa = new F32Array(capacity);
		_wb = new F32Array(capacity);
		_wc = new F32Array(capacity);
		_wd = new F32Array(capacity);
		_wx = new F32Array(capacity);
		_wy = new F32Array(capacity);

		_a = new F32Array(capacity);
		_b = new F32Array(capacity);
		_c = new F32Array(capacity);
		_d = new F32Array(capacity);
		_x = new F32Array(capacity);
		_y = new F32Array(capacity);

		_rotation = new F32Array(capacity);
		_scaleX = new F32Array(capacity);
		_scaleY = new F32Array(capacity);

		_mask = new CBitArray(capacity);

		_dirtyMask = new CBitArray(capacity);
		_dirtyVector = new EntityVector(1024);

		// initialize world identity const
		_wa[0] = 1.0;
		_wb[0] = 0.0;
		_wc[0] = 0.0;
		_wd[0] = 1.0;
		_wx[0] = 0.0;
		_wy[0] = 0.0;
	}

	inline public function create(entity:Entity) {
		_a[entity.id] = 1.0;
		_b[entity.id] = 0.0;
		_c[entity.id] = 0.0;
		_d[entity.id] = 1.0;
		_x[entity.id] = 0.0;
		_y[entity.id] = 0.0;

		_rotation[entity.id] = 0.0;
		_scaleX[entity.id] = 1.0;
		_scaleY[entity.id] = 1.0;

		_mask.enable(entity.id);
		markDirty(entity);
	}

	inline public function remove(entity:Entity) {
		_mask.disable(entity.id);
		_dirtyMask.disable(entity.id);
	}

	inline public function has(entity:Entity):Bool {
		return _mask.get(entity.id);
	}

	inline public function copy(source:Entity, destination:Entity):Void {
		_mask.enable(destination.id);

		_a[destination.id] = _a[source.id];
		_b[destination.id] = _b[source.id];
		_c[destination.id] = _c[source.id];
		_d[destination.id] = _d[source.id];
		_x[destination.id] = _x[source.id];
		_y[destination.id] = _y[source.id];

		_rotation[destination.id] = _rotation[source.id];
		_scaleX[destination.id] = _scaleX[source.id];
		_scaleY[destination.id] = _scaleY[source.id];

		markDirty(destination);
	}

	inline function markDirty(entity:Entity) {
		if(_dirtyMask.enableIfNot(entity.id)) {
			_dirtyVector.push(entity);
		}
	}
}
