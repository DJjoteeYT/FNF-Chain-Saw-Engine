package;

#if (cpp && !windows)
import cpp.vm.Gc;
#end
import haxe.Timer;
import flixel.FlxG;
import openfl.Lib;
import openfl.events.Event;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.system.System;

/**
 * Credits: Yoshubs.
 */
#if windows
@:headerCode("
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <psapi.h>
")
#end
class Overlay extends TextField
{
	private var times:Array<Float> = [];
	private var memPeak:Float = 0;

	public function new(x:Float, y:Float, color:Int)
	{
		super();

		this.x = x;
		this.y = x;

		this.autoSize = LEFT;
		this.selectable = false;
		this.mouseEnabled = false;

		this.defaultTextFormat = new TextFormat('_sans', 14, 0xFFFFFF);
		addEventListener(Event.ENTER_FRAME, function(e:Event)
		{
			var now = Timer.stamp();
			times.push(now);
			while (times[0] < now - 1)
				times.shift();

			var mem:Float = #if windows obtainMemory() #elseif cpp Gc.memInfo64(3) #else System.totalMemory.toFloat() #end;

			if (mem > memPeak)
				memPeak = mem;

			if (visible)
				text = times.length + ' FPS\n${getInterval(mem)} / ${getInterval(memPeak)}\n';
		});
	}

	static final intervalArray:Array<String> = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];

	public static function getInterval(size:Float):String
	{
		var data = 0;

		while (size > 1024 && data < intervalArray.length - 1)
		{
			data++;
			size = size / 1024;
		}

		size = Math.round(size * 100) / 100;
		return size + ' ' + intervalArray[data];
	}

	#if windows
	@:functionCode("
		auto memhandle = GetCurrentProcess();
		PROCESS_MEMORY_COUNTERS pmc;
		if (GetProcessMemoryInfo(memhandle, &pmc, sizeof(pmc)))
			return(pmc.WorkingSetSize);
		else
			return 0;
	")
	function obtainMemory():Dynamic
	{
		return 0;
	}
	#end
}
