package;

import flixel.FlxG;
import openfl.utils.Assets;

using StringTools;

class CoolUtil
{
	public static var difficultyArray:Array<String> = ['Easy', "Normal", "Hard"];

	public static function difficultyString(curDifficulty:Int):String
		return difficultyArray[curDifficulty];

	public static function coolTextFile(path:String):Array<String>
	{
		var daList:Array<String> = [];

		if (Assets.exists(path))
			daList = Assets.getText(path).trim().split('\n');

		for (i in 0...daList.length)
			daList[i] = daList[i].trim();

		return daList;
	}

	public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];

		for (i in min...max)
			dumbArray.push(i);

		return dumbArray;
	}

	public static function camLerpShit(ratio:Float)
		return FlxG.elapsed / (1 / 60) * ratio;

	public static function coolLerp(a:Float, b:Float, ratio:Float)
		return a + camLerpShit(ratio) * (b - a);
}
