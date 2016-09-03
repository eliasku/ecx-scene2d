package ecx.scene2d.components;

import ecx.types.EntityVector;
import ecx.scene2d.components.Argb32;
import ecx.ds.CBitArray;
import hotmem.I32Array;

class Color extends Service implements IComponent {

	/** Color interface **/

	public function setMultiplier(entity:Entity, r:Float = 1, g:Float = 1, b:Float = 1, a:Float = 1) {
		_localMultiplier[entity.id] = Argb32.makeFloats(r, g, b, a);
		markDirty(entity);
	}

	public function setOffset(entity:Entity, r:Float = 0, g:Float = 0, b:Float = 0) {
		_localOffset[entity.id] = Argb32.makeBytesRGB(Std.int(r), Std.int(g), Std.int(b));
		markDirty(entity);
	}

	inline public function setTransform(entity, rm:Float = 1, gm:Float = 1, bm:Float = 1, am:Float = 1,
							   ro:Float = 0, go:Float = 0, bo:Float = 0) {
		setColor32(entity, Argb32.makeFloats(rm, gm, bm, am), Argb32.makeBytesRGB(Std.int(ro), Std.int(go), Std.int(bo)));
	}

	public function setColor32(entity:Entity, multiplier:Argb32, offset:Argb32) {
		if(multiplier != _localMultiplier[entity.id] || offset != _localOffset[entity.id]) {
			_localMultiplier[entity.id] = multiplier;
			_localOffset[entity.id] = offset;
			markDirty(entity);
		}
	}

	@:keep
	inline public function getOffset32(entity:Entity):Argb32 {
		return _localOffset[entity.id];
	}

	@:keep
	public function setOffset32(entity:Entity, offset:Argb32) {
		if(offset != _localOffset[entity.id]) {
			_localOffset[entity.id] = offset;
			markDirty(entity);
		}
	}

	@:keep
	inline public function getMultiplier32(entity:Entity):Argb32 {
		return _localMultiplier[entity.id];
	}

	@:keep
	inline public function setMultiplier32(entity:Entity, multiplier:Argb32) {
		if(multiplier != _localMultiplier[entity.id]) {
			_localMultiplier[entity.id] = multiplier;
			markDirty(entity);
		}
	}

	@:keep
	public function setAlpha(entity:Entity, alpha:Float) {
		var alpha8:Int = Std.int(alpha * 255);
		var multiplier:Argb32 = _localMultiplier[entity.id];
		if(multiplier.a != alpha8) {
			multiplier.a = alpha8;
			_localMultiplier[entity.id] = multiplier;
			markDirty(entity);
		}
	}

	@:keep
	inline public function getAlpha(entity:Entity):Float {
		return new Argb32(_localMultiplier[entity.id]).fa;
	}

	inline public function getWorldMultiplier32(entity:Entity):Argb32 {
		return _worldMultiplier[entity.id];
	}

	inline public function getWorldOffset32(entity:Entity):Argb32 {
		return _worldOffset[entity.id];
	}

	inline public function resetDirty(entity:Entity) {
		return _dirtyMask.disable(entity.id);
	}

	inline public function isDirty(entity:Entity):Bool {
		return _dirtyMask.get(entity.id);
	}

	inline function markDirty(entity:Entity) {
		if(_dirtyMask.enableIfNot(entity.id)) {
			_dirtyVector.push(entity);
		}
	}

	/** Component Storage **/

	var _worldMultiplier:I32Array;
	var _worldOffset:I32Array;
	var _localMultiplier:I32Array;
	var _localOffset:I32Array;

	var _mask:CBitArray;

	var _dirtyMask:CBitArray;
	var _dirtyVector:EntityVector;

	public function new() {}

	override function __allocate() {
		var capacity = world.capacity;
		_worldMultiplier = new I32Array(capacity);
		_worldOffset = new I32Array(capacity);
		_localMultiplier = new I32Array(capacity);
		_localOffset = new I32Array(capacity);

		_mask = new CBitArray(capacity);

		_dirtyMask = new CBitArray(capacity);
		_dirtyVector = new EntityVector(1024);
	}

	inline public function create(entity:Entity) {
		_localMultiplier[entity.id] = Argb32.ONE;
		_localOffset[entity.id] = Argb32.ZERO;
		_mask.enable(entity.id);
		markDirty(entity);
	}

	inline public function remove(entity:Entity) {
		_mask.disable(entity.id);
	}

	inline public function has(entity:Entity):Bool {
		return _mask.get(entity.id);
	}

	inline public function copy(source:Entity, destination:Entity):Void {
		_mask.enable(destination.id);
		_localMultiplier[destination.id] = _localMultiplier[source.id];
		_localOffset[destination.id] = _localOffset[source.id];
		markDirty(destination);
	}
}
