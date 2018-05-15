package ecx.scene2d.data;

import hotmem.F32;

@:final @:unreflective
class Rect {

	public var x:F32;
	public var y:F32;
	public var width:F32;
	public var height:F32;

	public var left(get, set):F32;
	public var right(get, set):F32;
	public var top(get, set):F32;
	public var bottom(get, set):F32;
	public var centerX(get, never):F32;
	public var centerY(get, never):F32;
	public var isEmpty(get, never):Bool;

	public function new(x:F32 = 0, y:F32 = 0, width:F32 = 0, height:F32 = 0) {
		set(x, y, width, height);
	}

	inline public function set(x:F32, y:F32, width:F32, height:F32) {
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
	}

	public function contains(x:F32, y:F32):Bool {

		// A little more complicated than usual due to proper handling of negative widths/heights
		x -= this.x;
		if (width >= 0) {
			if (x < 0 || x > width) {
				return false;
			}
		}
		else if (x > 0 || x < width) {
			return false;
		}

		y -= this.y;
		if (height >= 0) {
			if (y < 0 || y > height) {
				return false;
			}
		}
		else if (y > 0 || y < height) {
			return false;
		}

		return true;
	}

	public function clone(result:Rect = null):Rect {
		if (result == null) {
			result = new Rect();
		}
		result.set(x, y, width, height);
		return result;
	}

	public function equals(other:Rect):Bool {
		return x == other.x && y == other.y && width == other.width && height == other.height;
	}

	public function copyFrom(other:Rect) {
		x = other.x;
		y = other.y;
		width = other.width;
		height = other.height;
	}

	public function transformBounds(matrix:Matrix) {
		var minX = 1000000000.0;
		var maxX = -1000000000.0;
		var minY = 1000000000.0;
		var maxY = -1000000000.0;
		var rx;
		var ry;

		var x = this.x;
		var y = this.y;
		var w = width;
		var h = height;

		rx = x * matrix.a + y * matrix.c + matrix.tx;
		ry = x * matrix.b + y * matrix.d + matrix.ty;
		minX = minX < rx ? minX : rx;
		maxX = maxX > rx ? maxX : rx;
		minY = minY < ry ? minY : ry;
		maxY = maxY > ry ? maxY : ry;

		rx = (x + w) * matrix.a + y * matrix.c + matrix.tx;
		ry = (x + w) * matrix.b + y * matrix.d + matrix.ty;
		minX = minX < rx ? minX : rx;
		maxX = maxX > rx ? maxX : rx;
		minY = minY < ry ? minY : ry;
		maxY = maxY > ry ? maxY : ry;

		rx = (x + w) * matrix.a + (y + h) * matrix.c + matrix.tx;
		ry = (x + w) * matrix.b + (y + h) * matrix.d + matrix.ty;
		minX = minX < rx ? minX : rx;
		maxX = maxX > rx ? maxX : rx;
		minY = minY < ry ? minY : ry;
		maxY = maxY > ry ? maxY : ry;

		rx = x * matrix.a + (y + h) * matrix.c + matrix.tx;
		ry = x * matrix.b + (y + h) * matrix.d + matrix.ty;
		minX = minX < rx ? minX : rx;
		maxX = maxX > rx ? maxX : rx;
		minY = minY < ry ? minY : ry;
		maxY = maxY > ry ? maxY : ry;

		set(minX, minY, maxX - minX, maxY - minY);
	}

	public function toString():String {
		return '($x, $y, $width x $height)';
	}

	inline function get_left():F32 {
		return x;
	}

	inline function set_left(value:F32):F32 {
		width -= value - x;
		x = value;
		return value;
	}

	inline function get_top():F32 {
		return y;
	}

	inline function set_top(value:F32):F32 {
		height -= value - y;
		y = value;
		return value;
	}

	inline function get_right():F32 {
		return x + width;
	}

	inline function set_right(value:F32):F32 {
		width = value - x;
		return value;
	}

	inline function get_bottom():F32 {
		return y + height;
	}

	inline function set_bottom(value:F32):F32 {
		height = value - y;
		return value;
	}

	inline function get_centerX():F32 {
		return x + width / 2;
	}

	inline function get_centerY():F32 {
		return y + height / 2;
	}

	inline function get_isEmpty():Bool {
		return width <= 0 || height <= 0;
	}
}