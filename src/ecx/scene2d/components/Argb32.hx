package ecx.scene2d.components;

import hotmem.F32;

abstract Argb32(Int) to Int from Int {

	inline public static var ONE:Argb32 = 0xFFFFFFFF;
	inline public static var ZERO:Argb32 = 0x00000000;

	inline public static var WHITE:Argb32 = 0xFFFFFFFF;
	inline public static var TRANSPARENT:Argb32 = 0x00FFFFFF;
	inline public static var BLACK:Argb32 = 0xFF000000;
	inline public static var RED:Argb32 = 0xFFFF0000;
	inline public static var GREEN:Argb32 = 0xFF00FF00;
	inline public static var BLUE:Argb32 = 0xFF0000FF;
	inline public static var YELLOW:Argb32 = 0xFFFFFF00;

	public var a(get, set):Int;
	public var r(get, set):Int;
	public var g(get, set):Int;
	public var b(get, set):Int;

	public var fa(get, set):Float;
	public var fr(get, set):Float;
	public var fg(get, set):Float;
	public var fb(get, set):Float;

	public inline function new(argb:Int) {
		this = argb;
	}

	inline function get_a():Int { return (this >>> 24) & 0xFF; }
	inline function get_r():Int { return (this >> 16) & 0xFF; }
	inline function get_g():Int { return (this >> 8) & 0xFF; }
	inline function get_b():Int { return this & 0xFF; }

	inline function set_a(value:Int):Int { return this = ((value & 0xFF) << 24) | (this & 0x00FFFFFF); }
	inline function set_r(value:Int):Int { return this = ((value & 0xFF) << 16) | (this & 0xFF00FFFF); }
	inline function set_g(value:Int):Int { return this = ((value & 0xFF) << 8 ) | (this & 0xFFFF00FF); }
	inline function set_b(value:Int):Int { return this = ( value & 0xFF       ) | (this & 0xFFFFFF00); }

	inline function get_fa():Float { return a / 255.0; }
	inline function get_fr():Float { return r / 255.0; }
	inline function get_fg():Float { return g / 255.0; }
	inline function get_fb():Float { return b / 255.0; }

	inline function set_fa(value:Float):Float { a = Std.int(value * 255.0); return value; }
	inline function set_fr(value:Float):Float { r = Std.int(value * 255.0); return value; }
	inline function set_fg(value:Float):Float { g = Std.int(value * 255.0); return value; }
	inline function set_fb(value:Float):Float { b = Std.int(value * 255.0); return value; }

	public static function lerp(a:Argb32, b:Argb32, t:Float):Argb32 {
		return makeFloats(
			a.fr + (b.fr - a.fr) * t,
			a.fg + (b.fg - a.fg) * t,
			a.fb + (b.fb - a.fb) * t,
			a.fa + (b.fa - a.fa) * t
		);
	}

	inline public function toABGR():Argb32 {
		// swap to ABGR
		return swapRB(this);
	}

	inline public static function makeBytes(r:Int, g:Int, b:Int, a:Int):Argb32 {
		return new Argb32((a << 24) | (r << 16) | (g << 8) | b);
	}

	inline public static function makeBytesRGB(r:Int, g:Int, b:Int):Argb32 {
		return new Argb32((r << 16) | (g << 8) | b);
	}

	inline public static function makeFloats(r:Float, g:Float, b:Float, a:Float):Argb32 {
		return makeBytes(Std.int(r * 0xFF), Std.int(g * 0xFF), Std.int(b * 0xFF), Std.int(a * 0xFF));
	}

	inline static function swapRB(color:Int):Int {
		return (color & 0xFF00FF00) | ((color >> 16) & 0xFF) | ((color & 0xFF) << 16);
	}

	inline public function multiply(color:Argb32):Argb32 {
		return color == 0xFFFFFFFF ? this : Argb32.makeBytes(
			(r * color.r * 258) >>> 16,
			(g * color.g * 258) >>> 16,
			(b * color.b * 258) >>> 16,
			(a * color.a * 258) >>> 16
		);
	}

	inline public function getAdditivePabgr(additiveFactor:F32 = 0):Int {
		var alpha = a;
		return
			(Std.int(alpha * (1 - additiveFactor)) << 24) |
			((alpha * b * 258) & 0x00FF0000) |
			(((alpha * g * 258) & 0x00FF0000) >> 8) |
			((alpha * r * 258) >>> 16);
	}

	inline public function getPabgr():Int {
		var alpha = a;
		return
			(alpha << 24) |
			((alpha * b * 258) & 0x00FF0000) |
			(((alpha * g * 258) & 0x00FF0000) >> 8) |
			((alpha * r * 258) >>> 16);
	}
}
