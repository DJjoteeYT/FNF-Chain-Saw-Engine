package;

import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	var fpsCounter:Overlay;

	public function new()
	{
		super();

		addChild(new FlxGame(0, 0, TitleState, 1, 60, 60, true, false));

		fpsCounter = new Overlay(10, 10, 0xFFFFFF);
		addChild(fpsCounter);
	}
}
