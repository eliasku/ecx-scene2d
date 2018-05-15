package ecx.scene2d.data;

@:enum abstract NodeFlags(Int) from Int to Int {
	var VISIBLE = 1;
	var TOUCHABLE = 2;
}