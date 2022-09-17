package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.FlxBasic;
import flixel.addons.effects.FlxTrail;
import flixel.addons.display.FlxRuntimeShader;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.system.FlxSound;
import flixel.util.FlxTimer;
import hscript.Interp;
import hscript.Parser;
import openfl.Lib;
import openfl.utils.Assets;
import openfl.filters.BitmapFilter;
import openfl.filters.ShaderFilter;
import states.PlayState;

using StringTools;

/**
 * Class based from Wednesdays-Infidelty Mod.
 * Credits: lunarcleint.
 */
class ScriptCore extends FlxBasic
{
	public static var Function_Stop:Dynamic = 1;
	public static var Function_Continue:Dynamic = 0;

	public var interp:Interp;
	public var parser:Parser;

	public function new(file:String)
	{
		super();

		interp = new Interp();
		parser = new Parser();
		parser.allowJSON = true;
		parser.allowTypes = true;

		setVariable('Function_Stop', Function_Stop);
		setVariable('Function_Continue', Function_Continue);

		setVariable('Math', Math);
		setVariable('Reflect', Reflect);
		setVariable('Std', Std);
		setVariable('StringTools', StringTools);
		setVariable('Sys', Sys);
		setVariable('Date', Date);
		setVariable('DateTools', DateTools);

		setVariable('FlxG', FlxG);
		setVariable('FlxSprite', FlxSprite);
		setVariable('FlxCamera', FlxCamera);
		setVariable('FlxTimer', FlxTimer);
		setVariable('FlxTween', FlxTween);
		setVariable('FlxEase', FlxEase);
		setVariable('FlxMath', FlxMath);
		setVariable('FlxAtlasFrames', FlxAtlasFrames);
		setVariable('FlxSound', FlxSound);
		setVariable('FlxSpriteGroup', FlxSpriteGroup);
		setVariable('FlxTrail', FlxTrail);
		setVariable('FlxRuntimeShader', FlxRuntimeShader);

		setVariable('Assets', Assets);
		setVariable('BitmapFilter', BitmapFilter);
		setVariable('ShaderFilter', ShaderFilter);

		setVariable('Paths', Paths);
		setVariable('CoolUtil', CoolUtil);
		setVariable('Conductor', Conductor);
		setVariable('PreferencesData', PreferencesData);
		setVariable('PlayState', PlayState);

		try
		{
			interp.execute(parser.parseString(Assets.getText(file)));
		}
		catch (e:Dynamic)
			Lib.application.window.alert(e.message, "Hscript Error!");

		trace('Script Loaded Succesfully: $file');

		executeFunc('create', []);
	}

	public function setVariable(name:String, val:Dynamic):Void
	{
		if (interp == null)
			return;

		try
		{
			interp.variables.set(name, val);
		}
		catch (e:Dynamic)
			Lib.application.window.alert(e.message, "Hscript Error!");
	}

	public function getVariable(name:String):Dynamic
	{
		if (interp == null)
			return null;

		try
		{
			return interp.variables.get(name);
		}
		catch (e:Dynamic)
			Lib.application.window.alert(e.message, "Hscript Error!");

		return null;
	}

	public function removeVariable(name:String):Void
	{
		if (interp == null)
			return;

		try
		{
			interp.variables.remove(name);
		}
		catch (e:Dynamic)
			Lib.application.window.alert(e.message, "Hscript Error!");
	}

	public function existsVariable(name:String):Bool
	{
		if (interp == null)
			return false;

		try
		{
			return interp.variables.exists(name);
		}
		catch (e:Dynamic)
			Lib.application.window.alert(e.message, "Hscript Error!");

		return false;
	}

	public function executeFunc(funcName:String, args:Array<Dynamic>):Dynamic
	{
		if (interp == null)
			return null;

		if (existsVariable(funcName))
		{
			try
			{
				return Reflect.callMethod(null, getVariable(funcName), args);
			}
			catch (e:Dynamic)
				Lib.application.window.alert(e, "Hscript Error!");
		}

		return null;
	}

	override function destroy()
	{
		super.destroy();
		interp = null;
		parser = null;
	}
}
