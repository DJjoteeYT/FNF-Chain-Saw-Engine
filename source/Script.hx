package;

import flixel.FlxBasic;
import hscript.Interp;
import hscript.Parser;
import openfl.Lib;

/**
 * Class based from Wednesdays-Infidelty Mod.
 * Credits: lunarcleint.
 */
class Script extends FlxBasic
{
	public var interp:Interp;

	public function new(script:String)
	{
		super();

		interp = new Interp();

		var parser:Parser = new Parser();

		try
			interp.execute(parser.parseString(script));
		catch (e:Dynamic)
			Lib.application.window.alert(e.message, "Hscript Error!");
	}

	public function setVariable(name:String, val:Dynamic):Void
	{
		if (interp == null)
			return;

		interp.variables.set(name, val);
	}

	public function getVariable(name:String):Dynamic
	{
		if (interp == null)
			return null;

		return interp.variables.get(name);
	}

	public function executeFunc(funcName:String, ?args:Array<Any>):Dynamic
	{
		if (interp == null)
			return null;

		if (interp.variables.exists(funcName))
		{
			var func:Dynamic = interp.variables.get(funcName);
			if (args == null)
			{
				var result = null;

				try
					result = func();
				catch (e:Dynamic)
					trace('$e');

				return result;
			}
			else
			{
				var result:Dynamic = null;

				try
					result = Reflect.callMethod(null, func, args);
				catch (e:Dynamic)
					trace('$e');

				return result;
			}
		}

		return null;
	}

	override function destroy()
	{
		super.destroy();
		interp = null;
	}
}