package;

import sys.io.File;
import sys.FileSystem;
import openfl.Lib;

using StringTools;

/*  Simple File Tracer made by @Sirox, some code taken from @M.A. Jigsaw  */

class FT {
	public static function traceVariable(thing:Dynamic, var_name:String, alert:Bool = false) {
		var dateNow:String = Date.now().toString();
		dateNow = dateNow.replace(" ", "_");
		dateNow = dateNow.replace(":", "'");
		var fp:String = SUtil.getPath() + "logs/" + var_name + dateNow + ".txt";
		
		if (!FileSystem.exists(SUtil.getPath() + "logs/")) {
			FileSystem.createDirectory(SUtil.getPath() + "logs/");
		}
		
		var thingToSave:String = forceToString(thing);

		File.saveContent(fp, var_name + " = " + thingToSave + "\n");
		
		if (alert) {
			Lib.application.window.alert(var_name + ' = ' + thingToSave, 'File Tracer');
		}
	}
	
	public static function trace(thing:Dynamic, logName:String, alert:Bool = false) {
		var dateNow:String = Date.now().toString();
		dateNow = dateNow.replace(" ", "_");
		dateNow = dateNow.replace(":", "'");
		var fp:String = SUtil.getPath() + "logs/" + logName + dateNow + ".txt";
		
		if (!FileSystem.exists(SUtil.getPath() + "logs/")) {
			FileSystem.createDirectory(SUtil.getPath() + "logs/");
		}
		
		var thingToSave:String = forceToString(thing);

		File.saveContent(fp, thingToSave + "\n");
		
		if (alert) {
			Lib.application.window.alert(var_name + ' = ' + thingToSave, 'File Tracer');
		}
	}
	
	public static function forceToString(shit:Dynamic):String {
		var result:String = '';
		if (!Std.isOfType(shit, String)) {
			result = Std.string(shit);
		} else {
			result = shit;
		}
		return result;
	}
}