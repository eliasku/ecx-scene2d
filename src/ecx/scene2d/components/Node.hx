package ecx.scene2d.components;

import ecx.ds.CBitArray;
import ecx.scene2d.data.NodeFlags;
import ecx.common.components.Name;
import hotmem.I32Array;
import hotmem.U8Array;

class Node extends Service implements IComponent {

	var _name:Wire<Name>;

	inline public function firstChild(entity:Entity):Entity {
		return world.getEntity(_firstChild[entity.id]);
	}

	inline public function after(entity:Entity):Entity {
		return world.getEntity(_sibling[entity.id]);
	}

	inline public function parent(entity:Entity):Entity {
		return world.getEntity(_parent[entity.id]);
	}

	inline public function hasChildren(entity:Entity):Bool {
		return firstChild(entity).isValid;
	}

	inline public function insertAfter(entity:Entity, after:Entity) {
		_sibling[entity.id] = after.id;
		_parent[after.id] = _parent[entity.id];
	}

	public function lastChild(entity:Entity):Entity {
		var child = firstChild(entity);
		var last = child;
		while (child.isValid) {
			last = child;
			child = after(child);
		}
		return last;
	}

	public function append(entity:Entity, child:Entity) {
		var lastChild = lastChild(entity);
		if (lastChild.isValid) {
			_sibling[lastChild.id] = child.id;
		}
		else {
			_firstChild[entity.id] = child.id;
		}
		_parent[child.id] = entity.id;
	}

	public function prepend(entity:Entity, child:Entity) {
		var first = firstChild(entity);
		if (first.isValid) {
			_sibling[child.id] = first.id;
			_firstChild[entity.id] = child.id;
		}
		else {
			_firstChild[entity.id] = child.id;
		}
		_parent[child.id] = entity.id;
	}

	public function countChildren(entity:Entity):Int {
		var num = 0;
		var child = firstChild(entity);
		while (child.isValid) {
			++num;
			child = after(child);
		}
		return num;
	}

	public function findChild(entity:Entity, name:String):Entity {
		var child = firstChild(entity);
		while (child.isValid) {
			if (_name.get(child) == name) {
				return child;
			}
			child = after(child);
		}
		return Entity.INVALID;
	}

	inline public function nextFirst(current:Entity):Entity {
		var next:Entity = firstChild(current);
		if (next.isInvalid) {
			next = after(current);
			if (next.isInvalid) {
				next = parent(current);
			}
		}
		return next;
	}

	inline public function nextReturn(current:Entity):Entity {
		var next:Entity = after(current);
		if (next.isInvalid) {
			next = parent(current);
		}
		return next;
	}

	public function setVisible(entity:Entity, visible:Bool) {
		if (visible) {
			_flags[entity.id] |= NodeFlags.VISIBLE;
		}
		else {
			_flags[entity.id] &= ~(NodeFlags.VISIBLE);
		}
	}

	inline public function isVisible(entity:Entity):Bool {
		return (_flags[entity.id] & NodeFlags.VISIBLE) != 0;
	}

	inline public function isTouchable(entity:Entity):Bool {
		return (_flags[entity.id] & NodeFlags.TOUCHABLE) != 0;
	}

	public function setTouchable(entity:Entity, touchable:Bool) {
		if (touchable) {
			_flags[entity.id] |= NodeFlags.TOUCHABLE;
		}
		else {
			_flags[entity.id] &= ~(NodeFlags.TOUCHABLE);
		}
	}

	public function deleteChildren(entity:Entity) {
		var child = firstChild(entity);
		while (child.isValid) {
			var temp = child;
			child = after(child);
			deleteChildren(temp);
			world.delete(temp);
		}
	}

	public function removeFromParent(entity:Entity) {
		var parent:Entity = parent(entity);
		_parent[entity.id] = Entity.INVALID.id;
		var child = firstChild(parent);
		if(child == entity) {
			_firstChild[parent.id] = _sibling[child.id];
		}
		else {
			while(child.isValid) {
				if(after(child) == entity) {
					_sibling[child.id] = _sibling[entity.id];
					break;
				}
				child = after(child);
			}
		}
	}

	public function removeChildren(entity:Entity) {
		var child = firstChild(entity);
		_firstChild[entity.id] = Entity.INVALID.id;
		while(child.isValid) {
			var temp = child;
			child = after(child);
			_parent[temp.id] = Entity.INVALID.id;
			_sibling[temp.id] = Entity.INVALID.id;
		}
	}
//
//	inline public function next(current:Entity, previous:Entity):Entity {
//		var next:Entity = parent(previous) == current ? after(current) : firstChild(current);
//		if(next.isInvalid) {
//			next = after(current);
//			if(next.isInvalid) {
//				next = parent(current);
//			}
//		}
//		return next;
//	}

	/** Component Storage **/

	var _mask:CBitArray;
	var _parent:I32Array;
	var _sibling:I32Array;
	var _firstChild:I32Array;
	var _flags:U8Array;

	public function new() {}

	override function __allocate() {
		var capacity = world.capacity;
		_parent = new I32Array(capacity);
		_sibling = new I32Array(capacity);
		_firstChild = new I32Array(capacity);
		_flags = new U8Array(capacity);
		_mask = new CBitArray(capacity);
	}

	inline public function create(entity:Entity) {
		_mask.enable(entity.id);
		_parent[entity.id] = Entity.INVALID.id;
		_firstChild[entity.id] = Entity.INVALID.id;
		_sibling[entity.id] = Entity.INVALID.id;
		_flags[entity.id] = NodeFlags.VISIBLE | NodeFlags.TOUCHABLE;
	}

	inline public function remove(entity:Entity) {
		_mask.disable(entity.id);
		removeFromParent(entity);
		removeChildren(entity);
	}

	inline public function has(entity:Entity):Bool {
		return _mask.get(entity.id);
	}

	inline public function copy(source:Entity, destination:Entity):Void {
		_mask.enable(destination.id);
		_parent[destination.id] = Entity.INVALID.id;
		_firstChild[destination.id] = Entity.INVALID.id;
		_sibling[destination.id] = Entity.INVALID.id;
		_flags[destination.id] = _flags[source.id];
		var child = firstChild(source);
		var prev = Entity.INVALID;
		while(child.isValid) {
			var childCopy = world.clone(child);
			if(prev.isValid) {
				insertAfter(prev, childCopy);
			}
			else {
				append(destination, childCopy);
			}
			prev = childCopy;
			child = after(child);
		}
	}
}
