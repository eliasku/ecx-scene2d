import hxmake.haxelib.HaxelibExt;
import hxmake.idea.IdeaPlugin;
import hxmake.haxelib.HaxelibPlugin;

using hxmake.haxelib.HaxelibPlugin;

class EcxScene2dMake extends hxmake.Module {

	function new() {
		config.classPath = ["src"];
		config.testPath = ["test", "test-openfl/src"];
		config.dependencies = [
			"ecx" => "haxelib",
			"hotmem" => "haxelib"
		];
		config.devDependencies = [
			"ecx-common" => "haxelib",
			"utest" => "haxelib"
		];

		apply(HaxelibPlugin);
		apply(IdeaPlugin);

		library(function(ext:HaxelibExt) {
			ext.config.version = "0.1.0";
			ext.config.description = "Scene management for ECX";
			ext.config.url = "https://github.com/eliasku/ecx-scene2d";
			ext.config.tags = ["scene", "transform", "ecs", "ecx", "cross"];
			ext.config.contributors = ["eliasku"];
			ext.config.license = "MIT";
			ext.config.releasenote = "initial";

			ext.pack.includes = ["src", "haxelib.json", "README.md"];
		});

//		var tt = new TestTask();
//		tt.debug = true;
//		tt.targets = ["neko", "swf", "node", "js", "cpp", "java", "cs"];
//		tt.libraries = ["ecx", "ecx-scene2d", "hotmem"];
//		task("test", tt);
	}
}