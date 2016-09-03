package ecx.scene2d.systems;

import ecx.scene2d.components.Node;

class Scene extends Service {

	public var root(default, null):Entity;

	var _node:Wire<Node>;

	public function new() {}

	override function initialize() {
		root = world.create();
		_node.create(root);
		world.commit(root);
	}
}
