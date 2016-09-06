package ;

import ecx.common.systems.SystemRunner;
import ecx.common.systems.FpsMeter;
import flash.text.TextFieldAutoSize;
import flash.Lib;
import flash.text.TextField;
import ecx.System;
import ecx.Wire;

class Stats extends System {

	public var variables(default, null):Map<String, String> = new Map();

	var _fpsMeter:Wire<FpsMeter>;
	var _runner:Wire<SystemRunner>;
	var _tf:TextField;

	public function new() {}

	override function initialize() {
		_tf = new TextField();
		_tf.textColor = 0xFFFFFF;
		_tf.autoSize = TextFieldAutoSize.LEFT;
		Lib.current.stage.addChild(_tf);

		_runner.profile = true;
	}

	override function update() {
		var lines = [
			"fps: " + round2d(_fpsMeter.framesPerSecond),
			"[dt]: " + round2d(_fpsMeter.frameTimeAverage * 1000),
			#if flash
			"mem: " + Std.int((flash.system.System.totalMemoryNumber / 1024) / 1024) + " mb",
			#end
			"entities: " + world.used + " / " + world.capacity
		];

		lines.push("");

		for(key in variables.keys()) {
			lines.push(key + ": " + variables.get(key));
		}

		lines.push("");

		for(profile in _runner.profileData) {
			var timing = '${round2d(profile.updateTime * 1000)} + ${round2d(profile.invalidateTime * 1000)} ms';
			var timingMax = '${round2d(profile.updateTimeMax * 1000)} + ${round2d(profile.invalidateTimeMax * 1000)} ms';
			var entitiesInfo = 'changed: ${profile.changed}; removed: ${profile.removed}';
			lines.push('${profile.name} : $timing | max: $timingMax | $entitiesInfo');

		}

		_tf.text = lines.join("\n");
	}

	function round2d(f:Float):Float {
		return Std.int(f * 100) / 100;
	}
}
