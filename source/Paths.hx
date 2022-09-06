package;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.display.BitmapData;
import openfl.display3D.textures.Texture;
import openfl.media.Sound;
import openfl.system.System;
import openfl.utils.Assets;

using StringTools;

class Paths
{
	public static var currentTrackedAssets:Map<String, FlxGraphic> = [];
	public static var currentTrackedTextures:Map<String, Texture> = [];
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
					var isTexture:Bool = currentTrackedTextures.exists(key);
					if (isTexture)
					{
						var texture = currentTrackedTextures.get(key);
						texture.dispose();
						texture = null;
						currentTrackedTextures.remove(key);
					}
					Assets.cache.removeBitmapData(key);
					Assets.cache.clearBitmapData(key);
					Assets.cache.clear(key);
					FlxG.bitmap._cache.remove(key);
					obj.destroy();
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
				obj.destroy();
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

	inline static public function image(key:String, ?gpurender:Bool = false):FlxGraphic
		return returnGraphic('images/$key', gpurender);

	inline static public function getSparrowAtlas(key:String):FlxAtlasFrames
		return FlxAtlasFrames.fromSparrow(image(key), xml('images/$key'));

	inline static public function getPackerAtlas(key:String):FlxAtlasFrames
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key), txt('images/$key'));

	public static function returnGraphic(key:String, ?gpurender:Bool = false):FlxGraphic
	{
		var path:String = 'assets/$key.png';
		if (Assets.exists(path, IMAGE))
		{
			if (!currentTrackedAssets.exists(path))
			{
				var newGraphic:FlxGraphic = null;
				var bitmap:BitmapData = Assets.getBitmapData(path);

				if (gpurender)
				{
					switch (FlxG.save.data.render)
					{
						case 1:
							var texture = FlxG.stage.context3D.createTexture(bitmap.width, bitmap.height, BGRA, true);
							texture.uploadFromBitmapData(bitmap);
							currentTrackedTextures.set(path, texture);
							bitmap.dispose();
							bitmap.disposeImage();
							bitmap = null;
							newGraphic = FlxGraphic.fromBitmapData(BitmapData.fromTexture(texture), false, path);
						default:
							newGraphic = FlxGraphic.fromBitmapData(bitmap, false, path);
					}
				}
				else
					newGraphic = FlxGraphic.fromBitmapData(bitmap, false, path);

				newGraphic.persist = true;
				currentTrackedAssets.set(path, newGraphic);
			}

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
