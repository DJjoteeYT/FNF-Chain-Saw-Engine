package;

import flixel.FlxSprite;
import openfl.utils.Assets;

class HealthIcon extends FlxSprite
{
	/**
	 * Used for FreeplayState! If you use it elsewhere, prob gonna annoying
	 */
	public var sprTracker:FlxSprite;

	public var curCharacter:String = 'bf';
	public var isPlayer:Bool = false;

	public function new(curCharacter:String = 'bf', isPlayer:Bool = false)
	{
		super();

		this.curCharacter = curCharacter;
		this.isPlayer = isPlayer;

		if (Paths.returnGraphic('characters/' + curCharacter + '/icon') != null)
		{
			loadGraphic(Paths.returnGraphic('characters/' + curCharacter + '/icon'), true, 150, 150);
			animation.add(curCharacter, [0, 1], 0, false, isPlayer);
			animation.play(curCharacter);
		}
		else
		{
			loadGraphic(Paths.returnGraphic('characters/bf/icon'), true, 150, 150);
			animation.add('bf', [0, 1], 0, false, isPlayer);
			animation.play('bf');
		}

		switch (curCharacter)
		{
			case 'bf-pixel' | 'senpai' | 'senpai-angry' | 'spirit' | 'gf-pixel':
				antialiasing = false;
			default:
				antialiasing = true;
		}

		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}
