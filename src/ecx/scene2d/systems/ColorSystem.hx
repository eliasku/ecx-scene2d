package ecx.scene2d.systems;

import ecx.scene2d.components.Color;
import ecx.scene2d.components.Node;
import ecx.scene2d.data.Argb32;
import hotmem.U8Array;

class ColorSystem extends System {

	var _clamp255:U8Array;

	var _color:Wire<Color>;
	var _node:Wire<Node>;

	public function new() {}

	override function initialize() {
		_clamp255 = new U8Array(511);
		var clamp = _clamp255;
		for (i in 0...256) {
			clamp[i] = i;
		}
		for (i in 256...511) {
			clamp[i] = 255;
		}
	}

	@:access(ecx.scene2d.components)
	override function update() {
		for (entity in _color._dirtyVector) {
			if (_color.isDirty(entity) && world.isActive(entity)) {
				var topDirty = findTopDirty(entity);
				var parentTransform = findParentTransform(topDirty);
				invalidate(topDirty, parentTransform);
			}
		}
		_color._dirtyVector.reset();
	}

	function findTopDirty(entity:Entity):Entity {
		if (!_node.has(entity)) {
			return entity;
		}
		var topDirty = entity;
		var current = _node.getParent(entity);
		while (current.notNull()) {
			if (_color.has(current) && _color.isDirty(current)) {
				topDirty = current;
			}
			current = _node.getParent(current);
		}
		return topDirty;
	}

	function findParentTransform(entity:Entity):Entity {
		if (!_node.has(entity)) {
			return Entity.NULL;
		}

		var current = _node.getParent(entity);
		while (current.notNull()) {
			if (_color.has(current)) {
				return current;
			}
			current = _node.getParent(current);
		}

		return Entity.NULL;
	}

	@:access(ecx.scene2d.components)
	function invalidate(entity:Entity, parent:Entity) {
		if (_color.has(entity)) {
			if (parent.notNull()) {
				var leftMult = _color.getMultiplier32(entity);
				var rightMult = _color.getWorldMultiplier32(parent);
				var rr = rightMult.r;
				var rg = rightMult.g;
				var rb = rightMult.b;

				if (leftMult == Argb32.ONE) {
					_color._worldMultiplier[entity.id] = rightMult;
				}
				else {
					var la = leftMult.a;
					var lr = leftMult.r;
					var lg = leftMult.g;
					var lb = leftMult.b;
					var ra = rightMult.a;

					_color._worldMultiplier[entity.id] = Argb32.makeBytes(
						(lr * rr * 258) >>> 16,
						(lg * rg * 258) >>> 16,
						(lb * rb * 258) >>> 16,
						(la * ra * 258) >>> 16
					);
				}

				var leftOffset = _color.getOffset32(entity);
				var rightOffset = _color.getWorldOffset32(parent);
				if (leftOffset == 0) {
					_color._worldOffset[entity.id] = rightOffset;
				}
				else {
					var lor = leftOffset.r;
					var log = leftOffset.g;
					var lob = leftOffset.b;
					var ror = rightOffset.r;
					var rog = rightOffset.g;
					var rob = rightOffset.b;

					var clamp = _clamp255;
					_color._worldOffset[entity.id] = Argb32.makeBytesRGB(
						clamp[((lor * rr * 258) >>> 16) + ror],
						clamp[((log * rg * 258) >>> 16) + rog],
						clamp[((lob * rb * 258) >>> 16) + rob]
					);
				}
			}
			else {
				_color._worldMultiplier[entity.id] = _color._localMultiplier[entity.id];
				_color._worldOffset[entity.id] = _color._localOffset[entity.id];
			}

			_color.resetDirty(entity);
			parent = entity;
		}

		if (_node.has(entity)) {
			var child = _node.getFirstChild(entity);
			while (child.notNull()) {
				invalidate(child, parent);
				child = _node.getNextSibling(child);
			}
		}
	}
}
