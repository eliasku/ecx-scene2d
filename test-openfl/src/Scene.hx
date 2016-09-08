package ;

import ecx.scene2d.components.Node;
import ecx.Entity;
import ecx.Service;

class Scene extends Service {

	public var root:Entity;

	public function new() {}

	override function initialize() {
		root = world.create();
		world.resolve(Node).create(root);
	}
}
