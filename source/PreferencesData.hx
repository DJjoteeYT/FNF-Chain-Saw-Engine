package;

import Controls;
import flixel.FlxG;
import flixel.util.FlxSave;
import flixel.input.keyboard.FlxKey;
import lime.app.Application;
import openfl.Lib;

class PreferencesData
{
	public static var ghostTapping:Bool = true;
	public static var downScroll:Bool = false;
	public static var accuracyDisplay:Bool = true;
	public static var offset:Float = 0;
	public static var overlay:Bool = false;
	public static var framerate:Int = 60;
	public static var safeFrames:Int = 10;
	public static var accuracyMode:String = 'Accurate';
	public static var checkForUpdates:Bool = true;
	public static var autoPlay:Bool = true;
	public static var antialiasing:Bool = true;
	public static var flashing:Bool = true;

	public static var keyBinds:Map<String, Array<FlxKey>> = [
		'note_left' => [A, LEFT],
		'note_down' => [S, DOWN],
		'note_up' => [W, UP],
		'note_right' => [D, RIGHT],
		'ui_left' => [A, LEFT],
		'ui_down' => [S, DOWN],
		'ui_up' => [W, UP],
		'ui_right' => [D, RIGHT],
		'accept' => [SPACE, ENTER],
		'back' => [BACKSPACE, ESCAPE],
		'pause'	=> [ENTER, ESCAPE],
		'reset' => [R, NONE],
		'volume_mute' => [ZERO, NONE],
		'volume_up' => [NUMPADPLUS, PLUS],
		'volume_down' => [NUMPADMINUS, MINUS],
	];

	public static final defaultKeys:Map<String, Array<FlxKey>> = [
		'note_left' => [A, LEFT],
		'note_down' => [S, DOWN],
		'note_up' => [W, UP],
		'note_right' => [D, RIGHT],
		'ui_left' => [A, LEFT],
		'ui_down' => [S, DOWN],
		'ui_up' => [W, UP],
		'ui_right' => [D, RIGHT],
		'accept' => [SPACE, ENTER],
		'back' => [BACKSPACE, ESCAPE],
		'pause'	=> [ENTER, ESCAPE],
		'reset' => [R, NONE],
		'volume_mute' => [ZERO, NONE],
		'volume_up' => [NUMPADPLUS, PLUS],
		'volume_down' => [NUMPADMINUS, MINUS],
	];

	public static function write()
	{
		FlxG.save.data.ghostTapping = ghostTapping;
		FlxG.save.data.downScroll = downScroll;
		FlxG.save.data.accuracyDisplay = accuracyDisplay;
		FlxG.save.data.offset = offset;
		FlxG.save.data.overlay = overlay;
		FlxG.save.data.framerate = framerate;
		FlxG.save.data.safeFrames = safeFrames;
		FlxG.save.data.accuracyMode = accuracyMode;
		FlxG.save.data.checkForUpdates = checkForUpdates;
		FlxG.save.data.autoPlay = autoPlay;
		FlxG.save.data.antialiasing = antialiasing;
		FlxG.save.data.flashing = flashing;
		FlxG.save.flush();

		var save:FlxSave = new FlxSave();
		save.bind('controls_input', 'ninjamuffin99');
		save.data.keyBinds = keyBinds;
		save.flush();

		Conductor.recalculateTimings();
	}

	public static function load()
	{
		if (FlxG.save.data.ghostTapping != null)
			ghostTapping = FlxG.save.data.ghostTapping;

		if (FlxG.save.data.downScroll != null)
			downScroll = FlxG.save.data.downScroll;

		if (FlxG.save.data.accuracyDisplay != null)
			accuracyDisplay = FlxG.save.data.accuracyDisplay;

		if (FlxG.save.data.offset != null)
			offset = FlxG.save.data.offset;

		if (FlxG.save.data.offset != null)
			offset = FlxG.save.data.offset;

		if (FlxG.save.data.overlay != null)
			overlay = FlxG.save.data.overlay;

		if (FlxG.save.data.framerate != null)
		{
			framerate = FlxG.save.data.framerate;

			final refreshRate:Int = Application.current.window.displayMode.refreshRate;
			if(framerate != refreshRate)
			{
				framerate = refreshRate;
				if(framerate < 60)
					framerate = 60;
			}

			if(framerate > FlxG.drawFramerate)
			{
				FlxG.updateFramerate = framerate;
				FlxG.drawFramerate = framerate;
				Lib.current.stage.frameRate = framerate;
			}
			else
			{
				FlxG.drawFramerate = framerate;
				FlxG.updateFramerate = framerate;
				Lib.current.stage.frameRate = framerate;
			}
		}

		if (FlxG.save.data.safeFrames != null)
			safeFrames = FlxG.save.data.safeFrames;

		if (FlxG.save.data.accuracyMode != null)
			accuracyMode = FlxG.save.data.accuracyMode;

		if (FlxG.save.data.checkForUpdates != null)
			checkForUpdates = FlxG.save.data.checkForUpdates;

		if (FlxG.save.data.autoPlay != null)
			autoPlay = FlxG.save.data.autoPlay;

		if (FlxG.save.data.antialiasing != null)
			antialiasing = FlxG.save.data.antialiasing;

		if (FlxG.save.data.flashing != null)
			flashing = FlxG.save.data.flashing;

		if(FlxG.save.data.volume != null)
			FlxG.sound.volume = FlxG.save.data.volume;

		if (FlxG.save.data.mute != null)
			FlxG.sound.muted = FlxG.save.data.mute;

		var save:FlxSave = new FlxSave();
		save.bind('controls_input', 'ninjamuffin99');
		if(save != null && save.data.keyBinds != null)
		{
			var loadedControls:Map<String, Array<FlxKey>> = save.data.keyBinds;
			for (control => keys in loadedControls)
				keyBinds.set(control, keys);

			reloadControls();
		}

		write();
	}

	public static function reloadControls()
	{
		PlayerSettings.player1.controls.setKeyboardScheme(KeyboardScheme.Solo);

		FlxG.sound.muteKeys = copyKey(keyBinds.get('volume_mute'));
		FlxG.sound.volumeDownKeys = copyKey(keyBinds.get('volume_down'));
		FlxG.sound.volumeUpKeys = copyKey(keyBinds.get('volume_up'));
	}

	public static function copyKey(arrayToCopy:Array<FlxKey>):Array<FlxKey>
	{
		var copiedArray:Array<FlxKey> = arrayToCopy.copy();
		var i:Int = 0;
		var len:Int = copiedArray.length;

		while (i < len)
		{
			if(copiedArray[i] == NONE)
			{
				copiedArray.remove(NONE);
				--i;
			}
			i++;
			len = copiedArray.length;
		}

		return copiedArray;
	}
}