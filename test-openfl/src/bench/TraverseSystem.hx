package bench;

import core.Stats;
import flash.events.MouseEvent;
import flash.Lib;
import ecx.scene2d.components.Node;
import ecx.Wire;
import ecx.Entity;
import ecx.System;

class TraverseSystem extends System {

	var _node:Wire<Node>;
	var _stats:Wire<Stats>;

	var _root:Entity;
	var _mode:Int = 0;

	var _nodes:Int;
	var _post:Int;

	public function new() {}

	override function initialize() {
		Lib.current.stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
	}

	function onMouseDown(event:MouseEvent) {
		_mode = (_mode + 1) & 1;
	}

	override function update() {
		if(!_root) {
			createScene();
		}

		_nodes = 0;
		_post = 0;
		if(_mode == 0) {
			traverseNaive(_root);
		}
		else {
			traverseFast(_root);
		}

		_stats.variables.set("mode", Std.string(_mode));
		_stats.variables.set("nodes", Std.string(_nodes));
		_stats.variables.set("post", Std.string(_post));
	}

	function traverseNaive(entity:Entity) {
		// DO NODE ENTER PROCESSING
		++_nodes;

		var child = _node.getFirstChild(entity);
		while(child) {
			traverseNaive(child);
			child = _node.getNextSibling(child);
		}

		// DO NODE EXIT PROCESSING
		++_post;
	}

	function traverseFast(entity:Entity) {
		var current = _root;
		var next = _root;
		var forward = true;

		while(current) {
			if(current == next) {

				// DO NODE ENTER PROCESSING
				++_nodes;

				next = _node.getFirstChild(current);
				if(next) {
					current = next;
				}
			}
			else {

				// DO NODE EXIT PROCESSING
				++_post;

				next = _node.getNextSibling(current);
				current = next ? next : _node.getParent(current);
			}

//			if(backward) {
//
//				// DO NODE EXIT PROCESSING
//				++_post;
//
//				next = _node.after(current);
//				if(next.isInvalid) {
//					next = _node.parent(current);
//				}
//				else {
//					backward = false;
//				}
//				current = next;
//			}
//			else {
//
//				// DO NODE ENTER PROCESSING
//				++_nodes;
//
//				next = _node.firstChild(current);
//				if(next.isInvalid) {
//					backward = true;
//				}
//				else {
//					current = next;
//				}
//			}
//
//			if(_node.parent(previous) == current) {
//
//				// DO NODE EXIT PROCESSING
//				++_post;
//
//				previous = current;
//				current = _node.nextReturn(current);
//			}
//			else {
//
//				// DO NODE ENTER PROCESSING
//				++_nodes;
//
//				previous = current;
//				current = _node.firstChild(current);
//			}
		}
	}

	function createScene() {
		_root = createNode();
		for(i in 0...10) {
			var child1 = createNode();
			_node.append(_root, child1);
			for(i in 0...100) {
				var child2 = createNode();
				_node.append(child1, child2);
				for(i in 0...10) {
					var child3 = createNode();
					_node.append(child2, child3);
					for(i in 0...100) {
						var child4 = createNode();
						_node.append(child3, child4);
//						for(i in 0...10) {
//							var child5 = createNode();
//							_node.append(child4, child5);
//						}
					}
				}
			}
		}
	}

	function createNode() {
		var entity = world.create();
		_node.create(entity);
		return entity;
	}
}
