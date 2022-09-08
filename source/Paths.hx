package;

import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.display.BitmapData;
import openfl.media.Sound;
import openfl.system.System;
import openfl.utils.Assets;

using StringTools;

class Paths
{
	public static var currentTrackedAssets:Map<String, BitmapData> = [];
	public static var currentTrackedSounds:Map<String, Sound> = [];

	public static var localTrackedAssets:Array<String> = [];

	public static function clearUnusedMemory()
	{
		var counter:Int = 0;
		for (key in currentTrackedAssets.keys())
		{
			if (!localTrackedAssets.contains(key))
			{
				var obj = currentTrackedAssets.get(key);
				@:privateAccess
				if (obj != null)
				{
					Assets.cache.removeBitmapData(key);
					Assets.cache.clearBitmapData(key);
					Assets.cache.clear(key);
					FlxG.bitmap._cache.remove(key);
					currentTrackedAssets.remove(key);
					counter++;
				}
			}
		}

		System.gc();
	}

	public static function clearStoredMemory()
	{
		var counterAssets:Int = 0;

		@:privateAccess
		for (key in FlxG.bitmap._cache.keys())
		{
			var obj = FlxG.bitmap._cache.get(key);
			if (obj != null && !currentTrackedAssets.exists(key))
			{
				Assets.cache.removeBitmapData(key);
				Assets.cache.clearBitmapData(key);
				Assets.cache.clear(key);
				FlxG.bitmap._cache.remove(key);
				counterAssets++;
			}
		}

		var counterSound:Int = 0;
		for (key in currentTrackedSounds.keys())
		{
			if (!localTrackedAssets.contains(key) && key != null)
			{
				Assets.cache.removeSound(key);
				Assets.cache.clearSounds(key);
				currentTrackedSounds.remove(key);
				counterSound++;
			}
		}

		var counterLeft:Int = 0;
		for (key in Assets.cache.getKeys())
		{
			if (!localTrackedAssets.contains(key) && key != null)
			{
				Assets.cache.clear(key);
				counterLeft++;
			}
		}

		localTrackedAssets = [];
	}

	inline static public function txt(key:String):String
		return 'assets/$key.txt';

	inline static public function xml(key:String):String
		return 'assets/$key.xml';

	inline static public function json(key:String):String
		return 'assets/$key.json';

	inline static public function font(key:String):String
		return 'assets/fonts/$key';

	static public function sound(key:String, ?cache:Bool = true):Sound
		return returnSound('sounds/$key', cache);

	inline static public function music(key:String, ?cache:Bool = true):Sound
		return returnSound('music/$key', cache);

	inline static public function voices(song:String, ?cache:Bool = true):Sound
		return returnSound('songs/' + song.replace(' ', '-').toLowerCase() + '/Voices', cache);

	inline static public function inst(song:String, ?cache:Bool = true):Sound
		return returnSound('songs/' + song.replace(' ', '-').toLowerCase() + '/Inst', cache);

	inline static public function image(key:String, ?cache:Bool = true):FlxGraphic
		return returnGraphic('images/$key', cache);

	inline static public function getSparrowAtlas(key:String):FlxAtlasFrames
		return FlxAtlasFrames.fromSparrow(image(key), xml('images/$key'));

	inline static public function getPackerAtlas(key:String):FlxAtlasFrames
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key), txt('images/$key'));

	public static function returnGraphic(key:String, ?cache:Bool = true):BitmapData
	{
		var path:String = 'assets/$key.png';
		if (Assets.exists(path, IMAGE))
		{
			if (!currentTrackedAssets.exists(path))
				currentTrackedAssets.set(path, Assets.getBitmapData(path, cache));

			localTrackedAssets.push(path);
			return currentTrackedAssets.get(path);
		}

		trace('oh no $key its returning null NOOOO');
		return null;
	}

	public static function returnSound(key:String, ?cache:Bool = true):Sound
	{
		var path:String = 'assets/$key.ogg';

		if (Assets.exists(path, SOUND))
		{
			if (!currentTrackedSounds.exists(path))
				currentTrackedSounds.set(path, Assets.getSound(path, cache));

			localTrackedAssets.push(path);
			return currentTrackedSounds.get(path);
		}

		trace('oh no $key its returning null NOOOO');
		return null;
	}
}
