package ecx.scene2d.systems;

import ecx.scene2d.components.Node;
import ecx.scene2d.components.Transform;

class TransformSystem extends System {

	var _transform:Wire<Transform>;
	var _node:Wire<Node>;

//	var _invalidateCalls:Int = 0;
//	var _invalidatedNodes:Int = 0;

	public function new() {}

	@:access(ecx.scene2d.components)
	override function update() {
//		_invalidateCalls = 0;
//		_invalidatedNodes = 0;
		for (entity in _transform._dirtyVector) {
			if (_transform.isDirty(entity) && world.isActive(entity)) {
				var root = findTopDirty(entity);
				var parentTransform = findParentTransform(root);
				//invalidate(topDirty, parentTransform);
				var parent = _node.parent(root);
				if (parent.isValid) {
					root = _node.firstChild(parent);
				}
				invalidateSiblings(root, parentTransform);
			}
		}
		_transform._dirtyVector.reset();

//		world.resolve(Stats).variables.set("transform invalidate calls", Std.string(_invalidateCalls));
//		world.resolve(Stats).variables.set("transforms invalidated", Std.string(_invalidatedNodes));
	}

	function findTopDirty(entity:Entity):Entity {
		if (!_node.has(entity)) {
			return entity;
		}
		var topDirty = entity;
		var current = _node.parent(entity);
		while (current.isValid) {
			if (_transform.isDirty(current)) {
				topDirty = current;
			}
			current = _node.parent(current);
		}
		return topDirty;
	}

	function findParentTransform(entity:Entity):Entity {
		if (!_node.has(entity)) {
			return Entity.INVALID;
		}

		var current = _node.parent(entity);
		while (current.isValid) {
			if (_transform.has(current)) {
				return current;
			}
			current = _node.parent(current);
		}

		return Entity.INVALID;
	}

	@:access(ecx.scene2d.components)
	function invalidateSiblings(entity:Entity, parent:Entity) {
//		++_invalidateCalls;

		var pwa = _transform._wa[parent.id];
		var pwb = _transform._wb[parent.id];
		var pwc = _transform._wc[parent.id];
		var pwd = _transform._wd[parent.id];
		var pwx = _transform._wx[parent.id];
		var pwy = _transform._wy[parent.id];

		while (entity.isValid) {
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

//				++_invalidatedNodes;

				var child = _node.firstChild(entity);
				if (child.isValid) {
					invalidateAfter(child, entity);
				}
			}
			entity = _node.after(entity);
		}
	}

	@:access(ecx.scene2d.components)
	function invalidateAfter(entity:Entity, parent:Entity) {
//		++_invalidateCalls;

		var pwa = _transform._wa[parent.id];
		var pwb = _transform._wb[parent.id];
		var pwc = _transform._wc[parent.id];
		var pwd = _transform._wd[parent.id];
		var pwx = _transform._wx[parent.id];
		var pwy = _transform._wy[parent.id];

		while (entity.isValid) {
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
//				++_invalidatedNodes;
				parent = entity;
			}
			var child = _node.firstChild(entity);
			if (child.isValid) {
				invalidateAfter(child, parent);
			}
			entity = _node.after(entity);
		}
	}

//	@:access(ecx.scene2d.components)
//	function invalidate(entity:Entity, parent:Entity) {
//		if(_transform.has(entity)) {
//			var pwa = _transform._wa[parent.id];
//			var pwb = _transform._wb[parent.id];
//			var pwc = _transform._wc[parent.id];
//			var pwd = _transform._wd[parent.id];
//			var pwx = _transform._wx[parent.id];
//			var pwy = _transform._wy[parent.id];
//
//			var a = _transform._a[entity.id];
//			var b = _transform._b[entity.id];
//			var c = _transform._c[entity.id];
//			var d = _transform._d[entity.id];
//			var x = _transform._x[entity.id];
//			var y = _transform._y[entity.id];
//
//			_transform._wa[entity.id] = pwa * a + pwc * b;
//			_transform._wd[entity.id] = pwb * c + pwd * d;
//
//			_transform._wb[entity.id] = pwb * a + pwd * b;
//			_transform._wc[entity.id] = pwa * c + pwc * d;
//
//			_transform._wx[entity.id] = pwa * x + pwc * y + pwx;
//			_transform._wy[entity.id] = pwb * x + pwd * y + pwy;
//
//			_transform.resetDirty(entity);
//			parent = entity;
//		}
//
//		if(_node.has(entity)) {
//			var child = _node.firstChild(entity);
//			while(child.isValid) {
//				invalidate(child, parent);
//				child = _node.after(child);
//			}
//		}
//	}
}
