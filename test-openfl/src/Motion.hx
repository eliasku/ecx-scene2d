package ;

import ecx.AutoComp;

class Motion extends AutoComp<MotionData> {}

class MotionData {

	public var vx:Float = 0.0;
	public var vy:Float = 0.0;
	public var ax:Float = 0.0;
	public var ay:Float = 0.0;

	public function new () {}
}