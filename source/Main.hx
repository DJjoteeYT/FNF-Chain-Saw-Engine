package;

import flixel.FlxGame;
import openfl.Lib;
import openfl.display.Sprite;
import states.TitleState;

class Main extends Sprite
{
	public static var instance:Main = null;

	private var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	private var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	private var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	private var game:FlxGame;
	private var overlay:Overlay;

	public function new()
	{
		instance = this;

		super();

		SUtil.uncaughtErrorHandler();

		final stageWidth:Int = Lib.current.stage.stageWidth;
		final stageHeight:Int = Lib.current.stage.stageHeight;

		if (zoom == -1)
		{
			final ratioX:Float = stageWidth / gameWidth;
			final ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
		}

		SUtil.check();

		game = new FlxGame(gameWidth, gameHeight, TitleState, zoom, 60, 60, true, false);
		addChild(game);

		overlay = new Overlay(10, 10, 0xFFFFFF);
		addChild(overlay);
	}
}
