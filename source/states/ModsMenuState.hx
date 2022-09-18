package;

import flixel.FlxG;

class ModsMenuState extends MusicBeatState
{
	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		#if FUTURE_DISCORD_RCP
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		if (FlxG.sound.music != null && !FlxG.sound.music.playing)
			FlxG.sound.playMusic(Paths.music('freakyMenu'));

		persistentUpdate = persistentDraw = true;
	}
}