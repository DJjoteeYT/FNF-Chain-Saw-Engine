package;

import flixel.FlxG;
import states.PlayState;

class Ratings
{
	public static function GenerateLetterRank(accuracy:Float):String
	{
		var ranking:String = "?";

		if (accuracy == 0)
			return ranking;
		else if (PlayState.misses == 0 && PlayState.bads == 0 && PlayState.shits == 0 && PlayState.goods == 0) // Marvelous (SICK) Full Combo
			ranking = "MFC";
		else if (PlayState.misses == 0 && PlayState.bads == 0 && PlayState.shits == 0 && PlayState.goods >= 1) // Good Full Combo (Nothing but Goods & Sicks)
			ranking = "GFC";
		else if (PlayState.misses == 0)
			ranking = "FC";
		else if (PlayState.misses < 10)
			ranking = "SDCB";
		else
			ranking = "Clear";

		return ranking;
	}

	public static function CalculateRating(noteDiff:Float):String
	{
		final timingWindows = [166.0, 135.0, 90.0, 45.0];
		for (index in 0...timingWindows.length)
		{
			if (Math.abs(noteDiff) < (timingWindows[index] * Conductor.timeScale)
				&& Math.abs(noteDiff) >= (index + 1 > timingWindows.length - 1 ? 0 : timingWindows[index + 1]) * Conductor.timeScale)
			{
				switch (index)
				{
					case 0: // shit
						return "shit";
					case 1: // bad
						return "bad";
					case 2: // good
						return "good";
					case 3: // sick
						return "sick";
				}
			}
		}

		return "sick";
	}
}
