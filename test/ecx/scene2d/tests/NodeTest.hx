package ecx.scene2d.tests;

import utest.Assert;
import ecx.scene2d.components.Node;

class NodeTest extends BaseTest {

	var _node:Node;

	public function new() {
		super();
		_node = world.resolve(Node);
	}

	public function testFirstChild() {
		var entity = world.create();
		Assert.isFalse(_node.getFirstChild(entity).notNull());
		world.destroy(entity);

		entity = world.create();
		_node.create(entity);
		Assert.isFalse(_node.getFirstChild(entity).notNull());
		world.destroy(entity);

		entity = world.create();
		var child = world.create();
		_node.create(entity);
		_node.create(child);
		_node.append(entity, child);
		Assert.equals(child, _node.getFirstChild(entity));
		world.destroy(entity);
	}
}
