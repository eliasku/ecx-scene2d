package ecx.scene2d.systems;

import ecx.scene2d.components.Node;
import ecx.scene2d.components.Transform;

class TransformSystem extends System {

	var _transform:Wire<Transform>;
	var _node:Wire<Node>;

	public function new() {}

	@:access(ecx.scene2d.components)
	override function update() {
		for (entity in _transform._dirtyVector) {
			if (_transform.isDirty(entity) && world.isActive(entity)) {
				var root = findTopDirty(entity);
				var parentTransform = findParentTransform(root);
				var parent = _node.__getParent(root);
				if (parent.notNull()) {
					invalidateDirtySiblings(_node.__getFirstChild(parent), parentTransform);
				}
				else {
					invalidate(root, parentTransform);
				}
			}
		}
		_transform._dirtyVector.reset();
	}

	function findTopDirty(entity:Entity):Entity {
		if (!_node.has(entity)) {
			return entity;
		}
		var topDirty = entity;
		var current = _node.getParent(entity);
		while (current.notNull()) {
			if (_transform.isDirty(current)) {
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
			if (_transform.has(current)) {
				return current;
			}
			current = _node.getParent(current);
		}

		return Entity.NULL;
	}

	@:access(ecx.scene2d.components)
	function invalidateDirtySiblings(entity:Entity, parent:Entity) {
		var pwa = _transform._wa[parent.id];
		var pwb = _transform._wb[parent.id];
		var pwc = _transform._wc[parent.id];
		var pwd = _transform._wd[parent.id];
		var pwx = _transform._wx[parent.id];
		var pwy = _transform._wy[parent.id];

		while (entity.notNull()) {
			if (_transform.isDirty(entity)) {
				var a = _transform._a[entity.id];
				var b = _transform._b[entity.id];
				var c = _transform._c[entity.id];
				var d = _transform._d[entity.id];
				var x = _transform._x[entity.id];
				var y = _transform._y[entity.id];

				_transform._wa[entity.id] = pwa * a + pwc * b;
				_transform._wd[entity.id] = pwb * c + pwd * d;
				_transform._wb[entity.id] = pwb * a + pwd * b;
				_transform._wc[entity.id] = pwa * c + pwc * d;
				_transform._wx[entity.id] = pwa * x + pwc * y + pwx;
				_transform._wy[entity.id] = pwb * x + pwd * y + pwy;
				_transform.resetDirty(entity);

				var child = _node.__getFirstChild(entity);
				if (child.notNull()) {
					invalidateSiblings(child, entity);
				}
			}
			entity = _node.__getNextSibling(entity);
		}
	}

	@:access(ecx.scene2d.components)
	function invalidateSiblings(entity:Entity, parent:Entity) {
		var pwa = _transform._wa[parent.id];
		var pwb = _transform._wb[parent.id];
		var pwc = _transform._wc[parent.id];
		var pwd = _transform._wd[parent.id];
		var pwx = _transform._wx[parent.id];
		var pwy = _transform._wy[parent.id];

		while (entity.notNull()) {
			if (_transform.has(entity)) {
				var a = _transform._a[entity.id];
				var b = _transform._b[entity.id];
				var c = _transform._c[entity.id];
				var d = _transform._d[entity.id];
				var x = _transform._x[entity.id];
				var y = _transform._y[entity.id];

				_transform._wa[entity.id] = pwa * a + pwc * b;
				_transform._wd[entity.id] = pwb * c + pwd * d;
				_transform._wb[entity.id] = pwb * a + pwd * b;
				_transform._wc[entity.id] = pwa * c + pwc * d;
				_transform._wx[entity.id] = pwa * x + pwc * y + pwx;
				_transform._wy[entity.id] = pwb * x + pwd * y + pwy;
				_transform.resetDirty(entity);

				parent = entity;
			}
			var child = _node.__getFirstChild(entity);
			if (child.notNull()) {
				invalidateSiblings(child, parent);
			}
			entity = _node.__getNextSibling(entity);
		}
	}

	@:access(ecx.scene2d.components)
	function invalidate(entity:Entity, parent:Entity) {
		var pwa = _transform._wa[parent.id];
		var pwb = _transform._wb[parent.id];
		var pwc = _transform._wc[parent.id];
		var pwd = _transform._wd[parent.id];
		var pwx = _transform._wx[parent.id];
		var pwy = _transform._wy[parent.id];

		var a = _transform._a[entity.id];
		var b = _transform._b[entity.id];
		var c = _transform._c[entity.id];
		var d = _transform._d[entity.id];
		var x = _transform._x[entity.id];
		var y = _transform._y[entity.id];

		_transform._wa[entity.id] = pwa * a + pwc * b;
		_transform._wd[entity.id] = pwb * c + pwd * d;
		_transform._wb[entity.id] = pwb * a + pwd * b;
		_transform._wc[entity.id] = pwa * c + pwc * d;
		_transform._wx[entity.id] = pwa * x + pwc * y + pwx;
		_transform._wy[entity.id] = pwb * x + pwd * y + pwy;
		_transform.resetDirty(entity);

		invalidateSiblings(_node.__getFirstChild(entity), entity);
	}
}
