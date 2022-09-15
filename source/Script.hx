package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.effects.FlxTrail;
import flixel.addons.display.FlxRuntimeShader;
import flixel.math.FlxMath;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.system.FlxSound;
import flixel.FlxBasic;
import hscript.Interp;
import hscript.Parser;
import openfl.Lib;
import openfl.utils.Assets;
import states.PlayState;

using StringTools;

/**
 * Class based from Wednesdays-Infidelty Mod.
 * Credits: lunarcleint.
 */
class Script extends FlxBasic
{
	public var interp:Interp;
	public var parser:Parser;

	public function new(file:String)
	{
		super();

		interp = new Interp();
		parser = new Parser();
		parser.allowJSON = true;
		parser.allowTypes = true;

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

		setVariable('Paths', Paths);
		setVariable('CoolUtil', CoolUtil);
		setVariable('Conductor', Conductor);
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
