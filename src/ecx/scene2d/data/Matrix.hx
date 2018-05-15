package ecx.scene2d.data;

import hotmem.F32;

@:final
@:unreflective
class Matrix {

	public var tx:F32;
	public var ty:F32;
	public var a:F32;
	public var b:F32;
	public var c:F32;
	public var d:F32;

	public var rotation(get, never):F32;
	public var scaleX(get, never):F32;
	public var scaleY(get, never):F32;

	inline public function new(a:F32 = 1, b:F32 = 0, c:F32 = 0, d:F32 = 1, tx:F32 = 0, ty:F32 = 0) {
		this.a = a;
		this.b = b;
		this.c = c;
		this.d = d;
		this.tx = tx;
		this.ty = ty;
	}

	inline public function set(a:F32, b:F32, c:F32, d:F32, tx:F32, ty:F32) {
		this.a = a;
		this.b = b;
		this.c = c;
		this.d = d;
		this.tx = tx;
		this.ty = ty;
	}

	inline public function identity() {
		set(1.0, 0.0, 0.0, 1.0, 0.0, 0.0);
	}

	public function compose(x:F32, y:F32, scaleX:F32, scaleY:F32, rotation:F32) {
		var sin = Math.sin(rotation);
		var cos = Math.cos(rotation);
		set(cos * scaleX, sin * scaleX, -sin * scaleY, cos * scaleY, x, y);
	}

	inline public function concat(matrix:Matrix) {
		Matrix.multiply(matrix, this, this);
	}

	public function makeTransform(scaleX:F32, scaleY:F32, rotation:F32) {
		var sin = Math.sin(rotation);
		var cos = Math.cos(rotation);
		a = cos * scaleX;
		b = sin * scaleX;
		c = -sin * scaleY;
		d = cos * scaleY;
	}

	function get_rotation():F32 {
		var sy = Math.atan2(b, a);
		var sx = Math.atan2(-c, d);
		return sx == sy ? sy : 0;
	}

	function get_scaleX():F32 {
		var oldValue = Math.sqrt(a * a + b * b);
		return a < 0.0 ? -oldValue : oldValue;
	}

	function get_scaleY():F32 {
		var oldValue = Math.sqrt(c * c + d * d);
		return d < 0.0 ? -oldValue : oldValue;
	}

	public function copyFrom(m:Matrix) {
		a = m.a;
		b = m.b;
		c = m.c;
		d = m.d;
		tx = m.tx;
		ty = m.ty;
	}

	public function translate(x:F32, y:F32) {
		tx += a * x + c * y;
		ty += d * y + b * x;
	}

	public function scale(x:F32, y:F32) {
		a *= x;
		b *= x;
		c *= y;
		d *= y;
	}

	public function rotate(rotation:F32) {
		var sin = Math.sin(rotation);
		var cos = Math.cos(rotation);

		var t00 = a * cos + c * sin;
		var t01 = -a * sin + c * cos;
		a = t00;
		c = t01;

		var t10 = d * sin + b * cos;
		var t11 = d * cos - b * sin;
		b = t10;
		d = t11;
	}

	public function invert():Bool {
		var norm:F32 = determinant();

		if (norm == 0) {
			a = b = c = d = 0;
			tx = -tx;
			ty = -ty;
			return false;
		}

		norm = 1.0 / norm;
		var a1 = d * norm;
		d = a * norm;
		a = a1;
		b *= -norm;
		c *= -norm;

		var tx1 = -a * tx - c * ty;
		ty = -b * tx - d * ty;
		tx = tx1;

		return true;
	}

//	public function transform(x:F32, y:F32, ?result:Point):Point {
//		if (result == null) {
//			result = new Point();
//		}
//		result.x = x * a + y * c + tx;
//		result.y = x * b + y * d + ty;
//		return result;
//	}

	inline public function determinant():F32 {
		return a * d - c * b;
	}
//
//	public function inverseTransform(x:F32, y:F32, result:Point):Bool {
//		var det = determinant();
//		if (det == 0) {
//			return false;
//		}
//		x -= tx;
//		y -= ty;
//		result.x = (x * d - y * c) / det;
//		result.y = (y * a - x * b) / det;
//		return true;
//	}

	public inline static function multiply(left:Matrix, right:Matrix, result:Matrix) {
		var a = left.a * right.a + left.c * right.b;
		var b = left.b * right.a + left.d * right.b;
		var c = left.a * right.c + left.c * right.d;
		var d = left.b * right.c + left.d * right.d;
		var tx = left.a * right.tx + left.c * right.ty + left.tx;
		var ty = left.b * right.tx + left.d * right.ty + left.ty;

		result.a = a;
		result.c = c;
		result.tx = tx;
		result.b = b;
		result.d = d;
		result.ty = ty;
	}

	public function clone(?result:Matrix):Matrix {
		if (result == null) {
			result = new Matrix();
		}
		result.set(a, b, c, d, tx, ty);
		return result;
	}

//	public inline function equalsCombined(matrix2:Matrix, translation:Point):Bool {
//		return tx == translation.x && ty == translation.y &&
//		a == matrix2.a && b == matrix2.b &&
//		c == matrix2.c && d == matrix2.d;
//	}

	public inline function equals(matrix2:Matrix):Bool {
		return tx == matrix2.tx && ty == matrix2.ty &&
		a == matrix2.a && b == matrix2.b &&
		c == matrix2.c && d == matrix2.d;
	}

//	public inline function copyFromCombined(matrix2:Matrix, translation:Point) {
//		tx = translation.x;
//		ty = translation.y;
//		a = matrix2.a;
//		b = matrix2.b;
//		c = matrix2.c;
//		d = matrix2.d;
//	}

	public function toString():String {
		return '$a $b $c $d $tx $ty';
	}

//	public static function lerpCombined(start:Matrix, endMatrix:Matrix, endPosition:Point, ratio:F32, result:Matrix = null):Matrix {
//		if (result == null) {
//			result = new Matrix();
//		}
//		result.a = start.a + (endMatrix.a - start.a) * ratio;
//		result.b = start.b + (endMatrix.b - start.b) * ratio;
//		result.c = start.c + (endMatrix.c - start.c) * ratio;
//		result.d = start.d + (endMatrix.d - start.d) * ratio;
//		result.tx = start.tx + (endPosition.x - start.tx) * ratio;
//		result.ty = start.ty + (endPosition.y - start.ty) * ratio;
//		return result;
//	}

	public static function lerp(start:Matrix, end:Matrix, ratio:F32, result:Matrix = null):Matrix {
		if (result == null) {
			result = new Matrix();
		}
		result.a = start.a + (end.a - start.a) * ratio;
		result.b = start.b + (end.b - start.b) * ratio;
		result.c = start.c + (end.c - start.c) * ratio;
		result.d = start.d + (end.d - start.d) * ratio;
		result.tx = start.tx + (end.tx - start.tx) * ratio;
		result.ty = start.ty + (end.ty - start.ty) * ratio;
		return result;
	}
}
