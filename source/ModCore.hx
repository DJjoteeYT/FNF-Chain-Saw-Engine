package;

import polymod.Polymod;
import polymod.Polymod.ModMetadata;
import polymod.Polymod.PolymodError;
import polymod.backends.PolymodAssets.PolymodAssetType;
import polymod.format.ParseRules;

/**
 * Class based from Kade Engine.
 * Credits: KadeDev.
 */
class ModCore
{
	private static final API_VER = '1.0.0';
	private static final MOD_DIR = 'mods';

	private static final modExtensions:Map<String, PolymodAssetType> = [
		'mp3' => AUDIO_GENERIC,
		'ogg' => AUDIO_GENERIC,
		'wav' => AUDIO_GENERIC,
		'jpg' => IMAGE,
		'png' => IMAGE,
		'gif' => IMAGE,
		'tga' => IMAGE,
		'bmp' => IMAGE,
		'tif' => IMAGE,
		'tiff' => IMAGE,
		'txt' => TEXT,
		'xml' => TEXT,
		'json' => TEXT,
		'csv' => TEXT,
		'tsv' => TEXT,
		'mpf' => TEXT,
		'tsx' => TEXT,
		'tmx' => TEXT,
		'vdf' => TEXT,
		'frag' => TEXT,
		'vert' => TEXT,
		'ttf' => FONT,
		'otf' => FONT,
		'webm' => VIDEO,
		'mp4' => VIDEO,
		'mov' => VIDEO,
		'avi' => VIDEO,
		'mkv' => VIDEO
	];

	public static var localTrackedMods:Array<ModMetadata> = [];

	public static function reload():Void
	{
		#if FUTURE_POLYMOD
		trace('Reloading Polymod...');
		loadMods(getMods());
		#else
		trace("Polymod is not supported on your Platform!")
		#end
	}

	#if FUTURE_POLYMOD
	public static function loadMods(folders:Array<String>):Void
	{
		var loadedModlist:Array<ModMetadata> = Polymod.init({
			modRoot: SUtil.getPath() + MOD_DIR,
			dirs: folders,
			framework: OPENFL,
			apiVersion: API_VER,
			errorCallback: onError,
			parseRules: getParseRules(),
			extensionMap: modExtensions,
			ignoredFiles: Polymod.getDefaultIgnoreList()
		});

		trace('Loading Successful, ${loadedModlist.length} / ${folders.length} new mods.');

		for (mod in loadedModlist)
		{
			localTrackedMods.push(mod);
			trace('Name: ${mod.title}, [${mod.id}]');
		}

		#if debug
		var fileList = Polymod.listModFiles('IMAGE');
		trace('Installed mods added / replaced ${fileList.length} images');
		for (item in fileList)
			trace('* [$item]');

		var fileList = Polymod.listModFiles('TEXT');
		trace('Installed mods added / replaced ${fileList.length} text files');
		for (item in fileList)
			trace('* [$item]');

		var fileList = Polymod.listModFiles('MUSIC');
		trace('Installed mods added / replaced ${fileList.length} songs');
		for (item in fileList)
			trace('* [$item]');

		var fileList = Polymod.listModFiles('SOUNDS');
		trace('Installed mods added / replaced ${fileList.length} sounds');
		for (item in fileList)
			trace('* [$item]');
		#end
	}

	public static function getMods():Array<String>
	{
		var daList:Array<String> = [];

		trace('Searching for Mods...');

		for (i in Polymod.scan(SUtil.getPath() + MOD_DIR, '*.*.*', onError))
			daList.push(i.id);

		trace('Found ${daList.length} new mods.');

		return daList;
	}

	public static function getParseRules():ParseRules
	{
		var output = ParseRules.getDefault();
		output.addType("txt", TextFileFormat.LINES);
		return output;
	}

	static function onError(error:PolymodError):Void
	{
		switch (error.severity)
		{
			case NOTICE:
				trace(error.message);
			case WARNING:
				trace(error.message);
			case ERROR:
				trace(error.message);
		}
	}
	#end
}
