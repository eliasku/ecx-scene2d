package ecx.scene2d.tests;

class BaseTest {

	static var _TEST_WORLD:World;

	public var world(default, null):World;

	public function new() {
		if(_TEST_WORLD == null) {
			var config = new WorldConfig();
			config.include(new Scene2d());
			_TEST_WORLD = Engine.createWorld(config);
		}
		world = _TEST_WORLD;
	}
}
