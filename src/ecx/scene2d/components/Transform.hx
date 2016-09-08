package ecx.scene2d.components;

import ecx.scene2d.data.Matrix;
import hotmem.F32Array;
import hotmem.F32;
import ecx.types.EntityVector;
import ecx.ds.CBitArray;

class Transform extends Service implements IComponent {

	var _node:Wire<Node>;
	var _ancestors:Array<Entity> = [];
	var _tempTransformMatrix:Matrix = new Matrix();

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

	inline public function setPosition(entity:Entity, x:F32, y:F32) {
		_x[entity.id] = x;
		_y[entity.id] = y;
		markDirty(entity);
	}

	inline public function setScale(entity:Entity, scaleX:F32, scaleY:F32) {
		_scaleX[entity.id] = scaleX;
		_scaleY[entity.id] = scaleY;
		markDirty(entity);
		rebuildLocalMatrix(entity);
	}

	inline public function getRotation(entity:Entity):F32 {
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

	public function setLocalMatrix(entity:Entity, matrix:Matrix) {
		_a[entity.id] = matrix.a;
		_b[entity.id] = matrix.b;
		_c[entity.id] = matrix.c;
		_d[entity.id] = matrix.d;
		_x[entity.id] = matrix.tx;
		_y[entity.id] = matrix.ty;
		markDirty(entity);
	}

	public function getLocalMatrix(entity:Entity, outMatrix:Matrix) {
		outMatrix.a = _a[entity.id];
		outMatrix.b = _b[entity.id];
		outMatrix.c = _c[entity.id];
		outMatrix.d = _d[entity.id];
		outMatrix.tx = _x[entity.id];
		outMatrix.ty = _y[entity.id];
	}

	public function concatLocalMatrixTo(entity:Entity, outRightMatrix:Matrix) {
		var a = _a[entity.id];
		var b = _b[entity.id];
		var c = _c[entity.id];
		var d = _d[entity.id];
		var x = _x[entity.id];
		var y = _y[entity.id];

		var ra = outRightMatrix.a;
		var rb = outRightMatrix.b;
		var rc = outRightMatrix.c;
		var rd = outRightMatrix.d;
		var rx = outRightMatrix.tx;
		var ry = outRightMatrix.ty;

		outRightMatrix.a = a * ra + c * rb;
		outRightMatrix.b = b * ra + d * rb;
		outRightMatrix.c = a * rc + c * rd;
		outRightMatrix.d = b * rc + d * rd;

		outRightMatrix.tx = a * rx + c * ry + x;
		outRightMatrix.ty = b * rx + d * ry + y;
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

	inline public function destroy(entity:Entity) {
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

	public function getObjectSize():Int {
		return
			_mask.getObjectSize() +
			_wa.getObjectSize() +
			_wb.getObjectSize() +
			_wc.getObjectSize() +
			_wd.getObjectSize() +
			_wx.getObjectSize() +
			_wy.getObjectSize() +
			_a.getObjectSize() +
			_b.getObjectSize() +
			_c.getObjectSize() +
			_d.getObjectSize() +
			_x.getObjectSize() +
			_y.getObjectSize() +
			_rotation.getObjectSize() +
			_scaleX.getObjectSize() +
			_scaleY.getObjectSize() +
			_dirtyMask.getObjectSize() +
			_dirtyVector.getObjectSize();
	}

	inline function markDirty(entity:Entity) {
		if(_dirtyMask.enableIfNot(entity.id)) {
			_dirtyVector.push(entity);
		}
	}

	/**
		NULL `targetSpace` represents as `entity` root space
	**/
	public function getTransformationMatrix(entity:Entity, targetSpace:Entity, outMatrix:Matrix = null):Matrix {
		if (outMatrix == null) {
			outMatrix = new Matrix();
		}

		if (targetSpace == entity || !_node.has(entity)) {
			outMatrix.identity();
			return outMatrix;
		}

		var parent = _node.getParent(entity);
		if (targetSpace == parent) {
			if (has(entity)) {
				getLocalMatrix(entity, outMatrix);
			}
			else {
				outMatrix.identity();
			}
			return outMatrix;
		}

		var current = Entity.NULL;

		if (targetSpace.isNull()) {
			outMatrix.identity();
			current = entity;
			while (current.notNull()) {
				if (has(current)) {
					concatLocalMatrixTo(current, outMatrix);
				}
				current = _node.getParent(current);
			}
			return outMatrix;
		}

		// optimization
		if (_node.getParent(targetSpace) == entity) {
			if (has(targetSpace)) {
				getLocalMatrix(targetSpace, outMatrix);
				outMatrix.invert();
				return outMatrix;
			}
			outMatrix.identity();
			return outMatrix;
		}

		// 1. find a common parent of this and the trackTarget space
		var index = 0;
		var commonParent = Entity.NULL;
		current = entity;
		while (current.notNull()) {
			_ancestors[index++] = current;
			current = _node.getParent(current);
		}

		// TODO: optimize with pre-depth solution
		current = targetSpace;
		while (current.notNull() && _ancestors.indexOf(current) < 0) {
			current = _node.getParent(current);
		}

		if (current.notNull()) {
			commonParent = current;
		}
		else {
			throw 'Object not connected to targetSpace';
		}

		// 2. move up from this to common parent
		current = entity;
		outMatrix.identity();
		while (current != commonParent) {
			if (has(current)) {
				concatLocalMatrixTo(current, outMatrix);
			}
			current = _node.getParent(current);
		}

		if (commonParent == targetSpace) {
			return outMatrix;
		}

		// 3. now move up from targetSpace until we reach the common parent
		var matrix = _tempTransformMatrix;
		matrix.identity();
		current = targetSpace;
		while (current != commonParent) {
			if (has(current)) {
				concatLocalMatrixTo(current, matrix);
			}
			current = _node.getParent(current);
		}

		// 4. now combine two matrices
		matrix.invert();
		Matrix.multiply(outMatrix, matrix, outMatrix);
		return outMatrix;
	}
}
