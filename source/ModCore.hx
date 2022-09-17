package;

import polymod.Polymod;
import polymod.Polymod.PolymodError;
import polymod.backends.PolymodAssets.PolymodAssetType;
import polymod.format.ParseRules;

/**
 * Class based from Kade Engine.
 * Credits: KadeDev.
 */
class ModCore
{
	static final API_VER = '1.0.0';
	static final MOD_DIR = 'mods';

	public static function reload():Void
	{
		#if FUTURE_POLYMOD
		trace('Reloading Polymod...');
		loadMods();
		#else
		trace("Polymod is not supported on your Platform!")
		#end
	}

	#if FUTURE_POLYMOD
	public static function loadMods():Void
	{
		var loadedModlist = Polymod.init({
			/**
			 * root directory of all mods
			 */
			modRoot: SUtil.getPath() + MOD_DIR,

			/**
			 * directory names of one or more mods, relative to modRoot
			 */
			dirs: getMods(),

			/**
			 * the Haxe framework you're using (OpenFL, HEAPS, Kha, NME, etc..).
			 * If not provided, Polymod will attempt to determine this automatically.
			 */
			framework: OPENFL,

			/**
			 * semantic version of your game's Modding API (will generate errors & warnings)
			 */
			apiVersion: API_VER,

			/**
			 * callback for any errors generated during mod initialization
			 */
			errorCallback: onError,

			/**
			 * parsing rules for various data formats
			 */
			parseRules: getParseRules(),

			/**
			 * list of filenames to ignore in mods
			 */
			ignoredFiles: Polymod.getDefaultIgnoreList(),
		});

		trace('Loading Successful, ${loadedModlist.length} / ${getMods().length} new mods.');

		for (mod in loadedModlist)
			trace('Name: ${mod.title}, [${mod.id}]');

		var fileList = Polymod.listModFiles("IMAGE");
		trace('Installed mods added / replaced ${fileList.length} images');
		for (item in fileList)
			trace(' * [$item]');

		var fileList = Polymod.listModFiles("TEXT");
		trace('Installed mods added / replaced ${fileList.length} text files');
		for (item in fileList)
			trace(' * [$item]');

		var fileList = Polymod.listModFiles("MUSIC");
		trace('Installed mods added / replaced ${fileList.length} songs');
		for (item in fileList)
			trace(' * [$item]');

		var fileList = Polymod.listModFiles("SOUNDS");
		trace('Installed mods added / replaced ${fileList.length} sounds');
		for (item in fileList)
			trace(' * [$item]');
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
