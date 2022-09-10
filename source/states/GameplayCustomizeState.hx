package states;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.FlxCamera;
import flixel.math.FlxPoint;
import flixel.FlxObject;
import flixel.group.FlxGroup.FlxTypedGroup;
import openfl.ui.Keyboard;
import flixel.FlxSprite;
import flixel.FlxG;

class GameplayCustomizeState extends MusicBeatState
{
	var defaultX:Float = FlxG.width * 0.55 - 135;
	var defaultY:Float = FlxG.height / 2 - 50;

	var sick:FlxSprite;

	var text:FlxText;
	var blackBorder:FlxSprite;

	var bf:Character;
	var dad:Character;

	public override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Customizing Gameplay", null);
		#end

		persistentUpdate = persistentDraw = true;

		var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image("menuDesat"));
		menuBG.color = 0xFFea71fd;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = true;
		add(menuBG);

		sick = new FlxSprite().loadGraphic(Paths.image('sick'));
		sick.scrollFactor.set();
		add(sick);

		super.create();

		text = new FlxText(5, FlxG.height + 40, 0, "Drag around gameplay elements, R to reset, Escape to go back.", 12);
		text.scrollFactor.set();
		text.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		blackBorder = new FlxSprite(-30, FlxG.height + 40).makeGraphic((Std.int(text.width + 900)), Std.int(text.height + 600), FlxColor.BLACK);
		blackBorder.alpha = 0.5;

		add(blackBorder);

		add(text);

		FlxTween.tween(text, {y: FlxG.height - 18}, 2, {ease: FlxEase.elasticInOut});
		FlxTween.tween(blackBorder, {y: FlxG.height - 18}, 2, {ease: FlxEase.elasticInOut});

		if (!FlxG.save.data.changedHit)
		{
			FlxG.save.data.changedHitX = defaultX;
			FlxG.save.data.changedHitY = defaultY;
		}

		sick.x = FlxG.save.data.changedHitX;
		sick.y = FlxG.save.data.changedHitY;

		FlxG.mouse.visible = true;
	}

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		super.update(elapsed);

		if (FlxG.mouse.overlaps(sick) && FlxG.mouse.justReleased)
		{
			FlxG.save.data.changedHitX = sick.x;
			FlxG.save.data.changedHitY = sick.y;
			FlxG.save.data.changedHit = true;
		}
		else if (FlxG.mouse.overlaps(sick) && FlxG.mouse.pressed)
		{
			sick.x = FlxG.mouse.x - Std.int(sick.width / 2);
			sick.y = FlxG.mouse.y - Std.int(sick.height / 2);
		}

		if (FlxG.keys.justPressed.R)
		{
			sick.x = defaultX;
			sick.y = defaultY;
			FlxG.save.data.changedHitX = sick.x;
			FlxG.save.data.changedHitY = sick.y;
			FlxG.save.data.changedHit = false;
		}
		else if (controls.BACK)
		{
			FlxG.mouse.visible = false;
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new OptionsMenu());
		}
	}
}
