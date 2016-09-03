package ;

import ecx.scene2d.components.Node;
import ecx.scene2d.systems.Scene;
import flash.display.Sprite;
import flash.geom.Matrix;
import flash.geom.ColorTransform;
import flash.Lib;

import ecx.scene2d.components.Color;
import ecx.scene2d.components.Transform;

import ecx.Wire;
import ecx.Entity;
import ecx.Family;
import ecx.System;

class DisplaySystem extends System {

	var _container:Sprite;
	var _entities:Family<Display, Node>;
	var _display:Wire<Display>;
	var _transform:Wire<Transform>;
	var _color:Wire<Color>;
	var _node:Wire<Node>;
	var _scene:Wire<Scene>;

	// temp variables for syncronization
	var _matrix:Matrix = new Matrix();
	var _colorTransform:ColorTransform = new ColorTransform();

	public function new() {}

	override function initialize() {
		_container = new Sprite();
		Lib.current.stage.addChildAt(_container, 0);
	}

	override function update() {
		var current = _scene.root;
		var next = _scene.root;
		var forward = true;

		var index:Int = 0;

		while(current.isValid) {
			if(current == next) {

				// DO NODE ENTER PROCESSING
				if(_display.has(current)) {
					var sprite = _display.get(current);
					_container.setChildIndex(sprite, index);

					sync(current);

					++index;
				}

				next = _node.firstChild(current);
				if(next.isValid) {
					current = next;
				}
			}
			else {

				// DO NODE EXIT PROCESSING

				next = _node.after(current);
				current = next.isValid ? next : _node.parent(current);
			}
		}
	}

	override function onEntityAdded(entity:Entity, _) {
		_container.addChild(_display.get(entity));
		sync(entity);
	}

	override function onEntityRemoved(entity:Entity, _) {
		_container.removeChild(_display.get(entity));
	}

	@:access(ecx.scene2d.components)
	function sync(entity:Entity) {
		var sprite = _display.get(entity);

		_matrix.a = _transform._wa[entity.id];
		_matrix.b = _transform._wb[entity.id];
		_matrix.c = _transform._wc[entity.id];
		_matrix.d = _transform._wd[entity.id];
		_matrix.tx = _transform._wx[entity.id];
		_matrix.ty = _transform._wy[entity.id];
		sprite.transform.matrix = _matrix;

		var m = _color.getWorldMultiplier32(entity);
		var o = _color.getWorldOffset32(entity);
		_colorTransform.alphaMultiplier = m.fa;
		_colorTransform.redMultiplier = m.fr;
		_colorTransform.greenMultiplier = m.fg;
		_colorTransform.blueMultiplier = m.fb;
		_colorTransform.redOffset = o.r;
		_colorTransform.greenOffset = o.g;
		_colorTransform.blueOffset = o.b;
		sprite.transform.colorTransform = _colorTransform;
	}
}