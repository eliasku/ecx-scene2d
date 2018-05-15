package ecx.scene2d.components;

import ecx.ds.CBitArray;
import ecx.scene2d.data.NodeFlags;
import ecx.common.components.Name;
import hotmem.I32Array;
import hotmem.U8Array;

class Node extends Service implements IComponent {

	var _name:Wire<Name>;

	public function new() {}

	/**
		First child of entity.
		NULL will be returned if entity has no children,
		or entity has not Node component
	**/
	inline public function getFirstChild(entity:Entity):Entity {
		return has(entity) ? __getFirstChild(entity) : Entity.NULL;
	}

	/**
		Last child of entity.
		NULL will be returned if entity has no children,
		or entity has not Node component
	**/
	inline public function getLastChild(entity:Entity):Entity {
		return has(entity) ? __getLastChild(entity) : Entity.NULL;
	}

	/**
		Next sibling of the entity.
		NULL will be returned if entity has no next sibling,
		or entity has not Node component
	**/
	inline public function getNextSibling(entity:Entity):Entity {
		return has(entity) ? __getNextSibling(entity) : Entity.NULL;
	}

	/**
		Previous sibling of the entity.
		NULL will be returned if entity has no previous sibling,
		or entity has not Node component
	**/
	inline public function getPreviousSibling(entity:Entity):Entity {
		return has(entity) ? __getPrevSibling(entity) : Entity.NULL;
	}

	/**
		Parent of the entity.
		NULL will be returned if entity has not been added to any entity,
		or entity has not Node component
	**/
	inline public function getParent(entity:Entity):Entity {
		return has(entity) ? __getParent(entity) : Entity.NULL;
	}

	/**
		True if entity has at least one child.
		False if entity has no children or it has not Node component.
	**/
	inline public function hasChildren(entity:Entity):Bool {
		return getFirstChild(entity).notNull();
	}

	/**
		Insert `childAfter` next to the `entity`.
		Throws exception if `entity` has no parent.
		`childAfter` will be removed from it's current parent.
		If `childAfter` has not Node component, it will be added.
	**/
	public function insertAfter(entity:Entity, childAfter:Entity) {
		var par = getParent(entity);
		if (par.isNull()) throw "entity has no parent";
		if (!has(childAfter)) {
			create(childAfter);
		}
		removeFromParent(childAfter);
		var next = __getNextSibling(entity);
		_nextSibling[entity.id] = childAfter.id;
		_prevSibling[childAfter.id] = entity.id;
		if(next.notNull()) {
			_prevSibling[next.id] = childAfter.id;
			_nextSibling[childAfter.id] = next.id;
		}
		else {
			_lastChild[par.id] = childAfter.id;
		}
		_parent[childAfter.id] = _parent[entity.id];
	}

	/**
		Insert `childBefore` back to the `entity`.
		Throws exception if `entity` has no parent.
		`childBefore` will be removed from it's current parent.
		If `childBefore` has not Node component, it will be added.
	**/
	public function insertBefore(entity:Entity, childBefore:Entity) {
		var par = getParent(entity);
		if (par.isNull()) throw "entity has no parent";
		if (!has(childBefore)) {
			create(childBefore);
		}
		removeFromParent(childBefore);
		var prev = __getPrevSibling(entity);
		_prevSibling[entity.id] = childBefore.id;
		_nextSibling[childBefore.id] = entity.id;
		if(prev.notNull()) {
			_nextSibling[prev.id] = childBefore.id;
			_prevSibling[childBefore.id] = prev.id;
		}
		else {
			_firstChild[par.id] = childBefore.id;
		}
		_parent[childBefore.id] = _parent[entity.id];
	}

	/**
		Add `child` to `entity` to the end.
		If `child` or `entity` have no Node component, it will be created.
		`child` will be removed from it's current parent.
	**/
	public function append(entity:Entity, child:Entity) {
		if (!has(entity)) {
			create(entity);
		}
		if (!has(child)) {
			create(child);
		}

		if(__getParent(child).notNull()) {
			removeFromParent(child);
		}

		var tail = __getLastChild(entity);
		if (tail.notNull()) {
			_nextSibling[tail.id] = child.id;
			_prevSibling[child.id] = tail.id;
			_lastChild[entity.id] = child.id;
		}
		else {
			_firstChild[entity.id] = child.id;
			_lastChild[entity.id] = child.id;
		}
		_parent[child.id] = entity.id;
	}

	/**
		Add `child` to `entity` to the beginning.
		If `child` or `entity` have no Node component, it will be created.
		`child` will be removed from it's current parent.
	**/
	public function prepend(entity:Entity, child:Entity) {
		if (!has(entity)) {
			create(entity);
		}
		if (!has(child)) {
			create(child);
		}
		if(__getParent(child).notNull()) {
			removeFromParent(child);
		}

		var head = __getFirstChild(entity);
		if (head.notNull()) {
			_nextSibling[child.id] = head.id;
			_prevSibling[head.id] = child.id;
			_firstChild[entity.id] = child.id;
		}
		else {
			_firstChild[entity.id] = child.id;
			_lastChild[entity.id] = child.id;
		}
		_parent[child.id] = entity.id;
	}

	/**
		Number of children of `entity`.
		Returns 0 if `entity` has no Node component.

		Note: children will be counted in fast-traversing
		from the first to the last child of `entity`
	**/
	public function getChildrenCount(entity:Entity):Int {
		var num = 0;
		if (has(entity)) {
			var child = __getFirstChild(entity);
			while (child.notNull()) {
				++num;
				child = __getNextSibling(child);
			}
		}
		return num;
	}

	/**
		Search child with `name` in `entity`.
		Returns NULL if `entity` has no Node component.
	**/
	public function findChild(entity:Entity, name:String):Entity {
		if (has(entity)) {
			var child = __getFirstChild(entity);
			while (child.notNull()) {
				if (_name.get(child) == name) {
					return child;
				}
				child = __getNextSibling(child);
			}
		}
		return Entity.NULL;
	}

	/**
		Check if `entity` is visible.
		Returns `false` if `entity` has no Node component.
	**/
	inline public function isVisible(entity:Entity):Bool {
		return has(entity) && __getFlag(entity, NodeFlags.VISIBLE);
	}

	/**
		Check if `entity` is touchable.
		Returns `false` if `entity` has no Node component.
	**/
	inline public function isTouchable(entity:Entity):Bool {
		return has(entity) && __getFlag(entity, NodeFlags.TOUCHABLE);
	}

	/**
		Set `visible` flag to the `entity`.
		If `entity` has no Node, it will be created.
	**/
	public function setVisible(entity:Entity, visible:Bool) {
		if (!has(entity)) {
			create(entity);
		}
		__setFlag(entity, NodeFlags.VISIBLE, visible);
	}

	/**
		Set `touchable` flag to the `entity`.
		If `entity` has no Node, it will be created.
	**/
	public function setTouchable(entity:Entity, touchable:Bool) {
		if (!has(entity)) {
			create(entity);
		}
		__setFlag(entity, NodeFlags.TOUCHABLE, touchable);
	}

	/**
		Delete all children and sub-children of `entity`
		if `entity` has Node component.
	**/
	public function destroyChildren(entity:Entity) {
		if(!has(entity)) {
			return;
		}
		var child = __getFirstChild(entity);
		while (child.notNull()) {
			var temp = child;
			child = __getNextSibling(child);
			destroyChildren(temp);
			_mask.disable(temp.id);
			_parent[temp.id] = Entity.ID_NULL;
			world.destroy(temp);
		}
		_firstChild[entity.id] = Entity.ID_NULL;
		_lastChild[entity.id] = Entity.ID_NULL;
	}

	/**
		Remove `entity` from it's parent
		if `entity` has Node component and is a child.
	**/
	public function removeFromParent(entity:Entity) {
		if(!has(entity)) {
			return;
		}
		var parent = __getParent(entity);
		if(parent.isNull()) {
			return;
		}

		var prev = __getPrevSibling(entity);
		var next = __getNextSibling(entity);
		if(prev.notNull()) {
			_nextSibling[prev.id] = next.id;
		}
		else {
			_firstChild[parent.id] = next.id;
		}
		if(next.notNull()) {
			_prevSibling[next.id] = prev.id;
		}
		else {
			_lastChild[parent.id] = prev.id;
		}

		_parent[entity.id] = Entity.ID_NULL;
		_nextSibling[entity.id] = Entity.ID_NULL;
		_prevSibling[entity.id] = Entity.ID_NULL;
	}

	/**
		Remove all children of `entity`
		if `entity` has Node component and is a child.
	**/
	public function removeChildren(entity:Entity) {
		if(!has(entity)) {
			return;
		}
		var child = __getFirstChild(entity);
		while (child.notNull()) {
			var temp = child;
			child = __getNextSibling(child);
			_parent[temp.id] = Entity.ID_NULL;
			_nextSibling[temp.id] = Entity.ID_NULL;
			_prevSibling[temp.id] = Entity.ID_NULL;
		}
		_firstChild[entity.id] = Entity.ID_NULL;
		_lastChild[entity.id] = Entity.ID_NULL;
	}

	/**
		Returns true if entity is descendant of ancestor.
	**/
	public function isDescendant(entity:Entity, ancestor:Entity) {
		if(!has(entity) || !has(ancestor)) {
			return false;
		}

		while(entity.notNull()) {
			entity = __getParent(entity);
			if(entity == ancestor) {
				return true;
			}
		}

		return false;
	}

	/**
		Returns readable path of entity, from root to entity
		Used mostly for Debugging.
		Empty string "" is used for unnamed nodes.
	**/
	public function getPath(entity:Entity):String {
		var path = [];
		while (entity.notNull()) {
			var name = _name.get(entity);
			path.push(name != null ? name : "");
			entity = getParent(entity);
		}
		path.reverse();
		return path.join("/");
	}

	// Component Storage

	var _mask:CBitArray;
	var _parent:I32Array;
	var _nextSibling:I32Array;
	var _prevSibling:I32Array;
	var _firstChild:I32Array;
	var _lastChild:I32Array;
	var _flags:U8Array;

	override function __allocate() {
		var capacity = world.capacity;
		_parent = new I32Array(capacity);
		_nextSibling = new I32Array(capacity);
		_prevSibling = new I32Array(capacity);
		_firstChild = new I32Array(capacity);
		_lastChild = new I32Array(capacity);
		_flags = new U8Array(capacity);
		_mask = new CBitArray(capacity);

		root = world.create();
		create(root);
	}

	inline public function create(entity:Entity) {
		_mask.enable(entity.id);
		_parent[entity.id] = Entity.ID_NULL;
		_firstChild[entity.id] = Entity.ID_NULL;
		_lastChild[entity.id] = Entity.ID_NULL;
		_nextSibling[entity.id] = Entity.ID_NULL;
		_prevSibling[entity.id] = Entity.ID_NULL;
		_flags[entity.id] = NodeFlags.VISIBLE | NodeFlags.TOUCHABLE;
	}

	inline public function destroy(entity:Entity) {
		removeFromParent(entity);
		destroyChildren(entity);
		_mask.disable(entity.id);
	}

	inline public function has(entity:Entity):Bool {
		return _mask.get(entity.id);
	}

	inline public function copy(source:Entity, destination:Entity):Void {
		create(destination);

		var child = __getFirstChild(source);
		var prev = Entity.NULL;
		while (child.notNull()) {
			var childCopy = world.clone(child);
			if (prev.notNull()) {
				insertAfter(prev, childCopy);
			}
			else {
				append(destination, childCopy);
			}
			prev = childCopy;
			child = __getNextSibling(child);
		}
	}

	public function getObjectSize():Int {
		return
			_mask.getObjectSize() +
			_parent.getObjectSize() +
			_nextSibling.getObjectSize() +
			_prevSibling.getObjectSize() +
			_firstChild.getObjectSize() +
			_lastChild.getObjectSize() +
			_flags.getObjectSize();
	}

	// EXTRA UNSAFE METHODS

	inline public function __getFirstChild(entity:Entity):Entity {
		return world.getEntity(_firstChild[entity.id]);
	}

	inline public function __getLastChild(entity:Entity):Entity {
		return world.getEntity(_lastChild[entity.id]);
	}

	inline public function __getNextSibling(entity:Entity):Entity {
		return world.getEntity(_nextSibling[entity.id]);
	}

	inline public function __getPrevSibling(entity:Entity):Entity {
		return world.getEntity(_prevSibling[entity.id]);
	}

	inline public function __getParent(entity:Entity):Entity {
		return world.getEntity(_parent[entity.id]);
	}

	inline public function __getFlag(entity:Entity, flag:Int):Bool {
		return (_flags[entity.id] & flag) != 0;
	}

	public function __setFlag(entity:Entity, flag:Int, enabled:Bool) {
		if (enabled) {
			_flags[entity.id] |= flag;
		}
		else {
			_flags[entity.id] &= ~flag;
		}
	}
}
