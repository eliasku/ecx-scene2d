package ;

import ecx.common.systems.TimeSystem;
import ecx.Entity;
import ecx.scene2d.components.Node;
import ecx.scene2d.components.Color;
import ecx.Wire;
import ecx.scene2d.components.Transform;
import ecx.Family;
import flash.events.MouseEvent;
import flash.Lib;
import ecx.System;

class OpenflTest extends System {

	var _entities:Family<Display>;
	var _transform:Wire<Transform>;
	var _scene:Wire<Scene>;

	var _color:Wire<Color>;
	var _node:Wire<Node>;
	var _display:Wire<Display>;
	var _motion:Wire<Motion>;
	var _radius:Wire<CollisionRadius>;
	var _time:Wire<TimeSystem>;

	var _displaySystem:Wire<DisplaySystem>;

	var _layers:Array<Entity>;

	var _mouseDown:Bool = false;

	public function new() {}

	override function initialize() {
		Lib.current.stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		Lib.current.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		Lib.current.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
	}

	override function update() {

		if(_layers == null) {
			_layers = [];
			for(i in 0...10) {
				_layers.push(createLayer());
			}
		}

		if(_mouseDown) {
			var count = _displaySystem != null ? 10 : 1000;
			var mouseX = Lib.current.stage.mouseX;
			var mouseY = Lib.current.stage.mouseY;
			for(i in 0...count) {
				spawn(mouseX, mouseY);
			}
		}
	}

	function onMouseDown(event:MouseEvent) {
		_mouseDown = true;
	}

	function onMouseUp(event:MouseEvent) {
		_mouseDown = false;
	}

	function onMouseMove(event:MouseEvent) {
		if(_layers == null) {
			return;
		}

		var hw = Lib.current.stage.stageWidth / 2;
		var hh = Lib.current.stage.stageHeight / 2;
		var x = event.stageX;
		var y = event.stageY;
		var fx = - (x - hw) / hw;
		var fy = - (y - hh) / hh;

		for(i in 0..._layers.length) {
			_transform.setPosition(_layers[i], fx * 20 * i, fy * 20 * i);
		}
	}

	function spawn(x:Float, y:Float) {
		var entity = world.create();

		var layerIndex = Std.int(Math.random() * _layers.length);
		var radius = 4 + layerIndex * 4;
		_transform.create(entity);
		_transform.setPosition(entity, x, y);
		_color.create(entity);
		_node.create(entity);
		_node.prepend(_layers[layerIndex], entity);

		var motion = _motion.create(entity);

		var angle = Math.random() * Math.PI * 2;
		var force = 1.0 + Math.random();
		motion.vx = 100 * Math.cos(angle) * force;
		motion.vy = 100 * Math.sin(angle) * force;
		motion.ay = 100;

		_radius.set(entity, radius);

		if(_displaySystem != null) {
			var g = _display.create(entity).graphics;
			g.beginFill(0xFFFFFF, 1.0);
			g.drawCircle(0, 0, radius);
			g.endFill();
		}

		world.commit(entity);
	}

	function createLayer():Entity {
		var layer = world.create();

		_transform.create(layer);

		_color.create(layer);
		_color.setMultiplier(layer, Math.random(), Math.random(), Math.random(), 1.0);

		_node.create(layer);
		_node.append(_scene.root, layer);

		world.commit(layer);
		return layer;
	}
}
