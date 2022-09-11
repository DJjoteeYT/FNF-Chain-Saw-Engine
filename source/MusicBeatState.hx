package;

import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import openfl.Lib;
import Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.FlxCamera;
import flixel.FlxState;
import flixel.addons.ui.FlxUIState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.math.FlxRect;
import flixel.util.FlxTimer;

class MusicBeatState extends FlxState
{
	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;
	private var controls(get, never):Controls;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	override function create()
	{
		super.create();

		if (!FlxTransitionableState.skipNextTransOut)
		{
			var cam:FlxCamera = new FlxCamera();
			cam.bgColor.alpha = 0;
			FlxG.cameras.add(cam, false);
			cam.fade(FlxColor.BLACK, 0.7, true, function()
			{
				FlxTransitionableState.skipNextTransOut = false;
			});
		}
	}

	override function update(elapsed:Float)
	{
		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep && curStep > 0)
			stepHit();

		super.update(elapsed);
	}

	private function updateBeat():Void
	{
		lastBeat = curStep;
		curBeat = Math.floor(curStep / 4);
	}

	public static var currentColor = 0;

	private function updateCurStep():Void
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (Conductor.songPosition >= Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet);
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
	}

	public static function switchState(nextState:FlxState)
	{
		if (!FlxTransitionableState.skipNextTransIn)
		{
			var cam:FlxCamera = new FlxCamera();
			cam.bgColor.alpha = 0;
			FlxG.cameras.add(cam, false);
			cam.fade(FlxColor.BLACK, 0.7, false, function()
			{
				FlxG.switchState(nextState);
				FlxTransitionableState.skipNextTransIn = false;
			});
		}
		else
		{
			FlxG.switchState(nextState);
		}
	}
}
