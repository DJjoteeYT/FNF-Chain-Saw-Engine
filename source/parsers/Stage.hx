package parsers;

import openfl.utils.Assets;
import haxe.Json;

typedef SwagStage =
{
	var suffix:String;
	var zoom:Float;
	var girlfriend:Array<Float>;
	var dad:Array<Float>;
	var boyfriend:Array<Float>;
	var camPosGirlfriend:Array<Float>;
	var camPosDad:Array<Float>;
	var camPosBoyfriend:Array<Float>;
}

class Stage
{
	public static function loadJson(stage:String):SwagStage
		return parseJson(Paths.json('stages/' + stage + '/data'));

	public static function parseJson(path:String):SwagStage
	{
		var rawJson:String = '';

		if (Assets.exists(path))
			rawJson = Assets.getText(path);

		return Json.parse(rawJson);
	}
}
