package;

import openfl.utils.Assets;
import haxe.Json;

typedef SwagWeek =
{
	var songs:Array<Dynamic>;
	var locked:Bool;
	var weekCharacters:Array<String>;
	var weekName:String;
	var hideStoryMode:Bool;
	var hideFreeplay:Bool;
}

class Week
{
	public static var currentLoadedWeeks:Map<String, SwagWeek> = [];
	public static var weeksList:Array<String> = [];

	public static function loadJsons(isStoryMode:Bool = false)
	{
		currentLoadedWeeks.clear();
		weeksList = [];

		final list:Array<String> = CoolUtil.coolTextFile(Paths.txt('weeks/weekList'));
		for (i in 0...list.length)
		{
			if(!currentLoadedWeeks.exists(list[i]))
			{
				var week:SwagWeek = parseJson(Paths.json('weeks/' + list[i]));
				if(week != null)
				{
					if(week != null && (isStoryMode && !week.hideStoryMode) || (!isStoryMode && !week.hideFreeplay))
					{
						currentLoadedWeeks.set(list[i], week);
						weeksList.push(list[i]);
					}
				}
			}
		}
	}

	private static function parseJson(path:String):SwagWeek
	{
		var rawJson:String = null;

		if(Assets.exists(path))
			rawJson = Assets.getText(path);

		return Json.parse(rawJson);
	}
}
