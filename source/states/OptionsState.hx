package states;

import flixel.FlxG;
import flixel.FlxSprite;
import substates.ControlsSubState;
import substates.PreferencesSubState;
import flixel.group.FlxGroup.FlxTypedGroup;

class OptionsState extends MusicBeatState
{
	private final options:Array<String> = ['Preferences', 'Controls', 'Exit'];
	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var curSelected:Int = 0;

	override function create()
	{
		#if FUTURE_DISCORD_RCP
		DiscordClient.changePresence("Options Menu", null);
		#end

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.color = 0xFFea71fd;
		add(bg);

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		for (i in 0...options.length)
		{
			var optionText:Alphabet = new Alphabet(0, 0, options[i], true, false);
			optionText.screenCenter();
			optionText.y += (100 * (i - (options.length / 2))) + 50;
			grpOptions.add(optionText);
		}

		changeSelection();

		#if android
		addVirtualPad(UP_DOWN, A);
		#end

		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.UI_UP_P)
			changeSelection(-1);
		else if (controls.UI_DOWN_P)
			changeSelection(1);
		else if (FlxG.mouse.wheel != 0)
			changeSelection(-FlxG.mouse.wheel);

		if (controls.ACCEPT)
		{
			#if android
			if (options[curSelected] != 'Exit')
				removeVirtualPad();
			#end

			switch (options[curSelected])
			{
				case 'Preferences':
					openSubState(new PreferencesSubState());
				case 'Controls':
					openSubState(new ControlsSubState());
				case 'Exit':
					FlxG.sound.play(Paths.sound('cancelMenu'));
					MusicBeatState.switchState(new MainMenuState());
			}
		}
	}

	private function changeSelection(change:Int = 0)
	{
		curSelected += change;

		if (curSelected < 0)
			curSelected = options.length - 1;
		else if (curSelected >= options.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpOptions.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			if (item.targetY == 0)
				item.alpha = 1;
		}

		FlxG.sound.play(Paths.sound('scrollMenu'));
	}
}
