package;

import flixel.FlxG;
import substates.KeyBindMenu;
import states.GameplayCustomizeState;
import states.OptionsMenu;

class OptionCategory
{
	private var _options:Array<Option> = new Array<Option>();

	public final function getOptions():Array<Option>
		return _options;

	public final function addOption(opt:Option)
		_options.push(opt);

	public final function removeOption(opt:Option)
		_options.remove(opt);

	private var _name:String = "New Category";

	public final function getName()
		return _name;

	public function new(catName:String, options:Array<Option>)
	{
		_name = catName;
		_options = options;
	}
}

class Option
{
	public function new()
		display = updateDisplay();

	private var description:String = "";
	private var display:String;
	private var acceptValues:Bool = false;

	public final function getDisplay():String
		return display;

	public final function getAccept():Bool
		return acceptValues;

	public final function getDescription():String
		return description;

	public function getValue():String
		return throw "stub!";

	public function press():Bool
		return throw "stub!";

	private function updateDisplay():String
		return throw "stub!";

	public function left():Bool
		return throw "stub!";

	public function right():Bool
		return throw "stub!";
}

class DFJKOption extends Option
{
	private var controls:Controls;

	public function new(controls:Controls)
	{
		super();
		this.controls = controls;
	}

	public override function press():Bool
	{
		OptionsMenu.instance.openSubState(new KeyBindMenu());
		return false;
	}

	private override function updateDisplay():String
		return "Key Bindings";
}

class CpuStrums extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.cpuStrums = !FlxG.save.data.cpuStrums;

		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
		return FlxG.save.data.cpuStrums ? "Light CPU Strums" : "CPU Strums stay static";
}

class DownscrollOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.downscroll = !FlxG.save.data.downscroll;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
		return FlxG.save.data.downscroll ? "Downscroll" : "Upscroll";
}

class GhostTapOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.ghost = !FlxG.save.data.ghost;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
		return FlxG.save.data.ghost ? "Ghost Tapping" : "No Ghost Tapping";
}

class AccuracyOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.accuracyDisplay = !FlxG.save.data.accuracyDisplay;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
		return "Accuracy " + (!FlxG.save.data.accuracyDisplay ? "off" : "on");
}

class SongPositionOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.songPosition = !FlxG.save.data.songPosition;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
		return "Song Position " + (!FlxG.save.data.songPosition ? "off" : "on");
}

class DistractionsAndEffectsOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.distractions = !FlxG.save.data.distractions;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
		return "Distractions " + (!FlxG.save.data.distractions ? "off" : "on");
}

class ResetButtonOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.resetButton = !FlxG.save.data.resetButton;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
		return "Reset Button " + (!FlxG.save.data.resetButton ? "off" : "on");
}

class FlashingLightsOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.flashing = !FlxG.save.data.flashing;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
		return "Flashing Lights " + (!FlxG.save.data.flashing ? "off" : "on");
}

class Judgement extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptValues = true;
	}

	public override function press():Bool
		return true;

	private override function updateDisplay():String
		return "Safe Frames";

	override function left():Bool
	{
		if (Conductor.safeFrames == 1)
			return false;

		Conductor.safeFrames -= 1;
		FlxG.save.data.frames = Conductor.safeFrames;

		Conductor.recalculateTimings();
		return true;
	}

	override function getValue():String
		return "Safe Frames: "
			+ Conductor.safeFrames
			+ " - SIK: "
			+ CoolUtil.truncateFloat(45 * Conductor.timeScale, 0)
			+ "ms GD: "
			+ CoolUtil.truncateFloat(90 * Conductor.timeScale, 0)
			+ "ms BD: "
			+ CoolUtil.truncateFloat(135 * Conductor.timeScale, 0)
			+ "ms SHT: "
			+ CoolUtil.truncateFloat(155 * Conductor.timeScale, 0)
			+ "ms TOTAL: "
			+ CoolUtil.truncateFloat(Conductor.safeZoneOffset, 0)
			+ "ms";

	override function right():Bool
	{
		if (Conductor.safeFrames == 20)
			return false;

		Conductor.safeFrames += 1;
		FlxG.save.data.frames = Conductor.safeFrames;

		Conductor.recalculateTimings();
		return true;
	}
}

class OverlayOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.overlay = !FlxG.save.data.overlay;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
		return "Overlay " + (!FlxG.save.data.overlay ? "off" : "on");
}

class ScrollSpeedOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptValues = true;
	}

	public override function press():Bool
		return false;

	private override function updateDisplay():String
		return "Scroll Speed";

	override function right():Bool
	{
		FlxG.save.data.scrollSpeed += 0.1;

		if (FlxG.save.data.scrollSpeed < 1)
			FlxG.save.data.scrollSpeed = 1;

		if (FlxG.save.data.scrollSpeed > 4)
			FlxG.save.data.scrollSpeed = 4;

		return true;
	}

	override function getValue():String
		return "Current Scroll Speed: " + CoolUtil.truncateFloat(FlxG.save.data.scrollSpeed, 1);

	override function left():Bool
	{
		FlxG.save.data.scrollSpeed -= 0.1;

		if (FlxG.save.data.scrollSpeed < 1)
			FlxG.save.data.scrollSpeed = 1;

		if (FlxG.save.data.scrollSpeed > 4)
			FlxG.save.data.scrollSpeed = 4;

		return true;
	}
}

class AccuracyDOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.accuracyMod = FlxG.save.data.accuracyMod == 1 ? 0 : 1;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
		return "Accuracy Mode: " + (FlxG.save.data.accuracyMod == 0 ? "Accurate" : "Complex");
}

class CustomizeGameplay extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		trace("switch");
		MusicBeatState.switchState(new GameplayCustomizeState());
		return false;
	}

	private override function updateDisplay():String
		return "Customize Gameplay";
}

class BotPlay extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.botplay = !FlxG.save.data.botplay;
		trace('BotPlay : ' + FlxG.save.data.botplay);
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
		return "BotPlay " + (FlxG.save.data.botplay ? "on" : "off");
}
