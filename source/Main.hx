package;

import flixel.FlxGame;
import lime.app.Application;
import openfl.display.Sprite;
import states.TitleState;

class Main extends Sprite
{
	public function new()
	{
		super();

		addChild(new FlxGame(0, 0, TitleState, 1, 60, 60, true, false));
		addChild(new Overlay(10, 10, 0xFFFFFF));

		PlayerSettings.init();
		PreferencesData.load();
		HighScore.load();

		#if desktop
		DiscordClient.initialize();

		Application.current.onExit.add(function(exitCode:Int)
		{
			DiscordClient.shutdown();
		});
		#end
	}
}
