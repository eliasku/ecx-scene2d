package ecx.scene2d;

import ecx.scene2d.systems.Scene;
import ecx.scene2d.systems.ColorSystem;
import ecx.scene2d.systems.TransformSystem;
import ecx.scene2d.components.Node;
import ecx.scene2d.components.Transform;
import ecx.scene2d.components.Color;

class Scene2d extends WorldConfig {

	inline public static var PRIORITY_INVALIDATE:Int = 100;

	public function new() {

		super();

		// Services
		add(new Scene());

		// Systems
		add(new TransformSystem(), PRIORITY_INVALIDATE);
		add(new ColorSystem(), PRIORITY_INVALIDATE);

		// Components
		add(new Node());
		add(new Color());
		add(new Transform());

//		require([
//			new Scene(false) => 0,
//
//			TransformSystem => PRIORITY_INVALIDATE,
//			ColorSystem => PRIORITY_INVALIDATE,
//
//			Node,
//			Color,
//			Transform,
//			Name
//		]);


//		// Services
//		require(Scene);
//
//		// Systems
//		require(TransformSystem, PRIORITY_INVALIDATE);
//		require(ColorSystem, PRIORITY_INVALIDATE);
//
//		// Components
//		require(Node);
//		require(Color);
//		require(Transform);
//		require(Name);
	}
}
