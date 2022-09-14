package substates;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.group.FlxGroup.FlxTypedGroup;
import ui.CheckboxThingie;

using StringTools;

class PreferencesSubState extends MusicBeatSubstate
{
	private var curSelected:Int = 0;

	private var options:Array<Dynamic> = [
		['Ghost Tapping', PreferencesData.ghostTapping],
		['Downscroll', PreferencesData.downScroll],
		['Accuracy-Display', PreferencesData.accuracyDisplay],
		['Overlay', PreferencesData.overlay],
		['Check For Updates', PreferencesData.checkForUpdates],
		['Auto-Play', PreferencesData.autoPlay],
		['Antialiasing', PreferencesData.antialiasing],
		['Flashing', PreferencesData.flashing]
	];

	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var checkboxArray:Array<CheckboxThingie> = [];

	public function new()
	{
		super();

		#if desktop
		DiscordClient.changePresence("Preferences Menu", null);
		#end

		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.color = 0xFFea71fd;
		bg.screenCenter();
		add(bg);

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		for (i in 0...options.length)
		{
			var optionText:Alphabet = new Alphabet(0, 70 * i, options[i][0], false, false);
			optionText.isMenuItem = true;
			optionText.targetY = i;
			grpOptions.add(optionText);

			var checkbox:CheckboxThingie = new CheckboxThingie(0, 0, false);
			checkbox.sprTracker = optionText;
			checkboxArray.push(checkbox);
			checkbox.ID = i;
			add(checkbox);
		}

		changeSelection();
		reloadValues();
	}

	override function update(elapsed:Float)
	{
		if (controls.UI_UP_P)
			changeSelection(-1);
		else if (controls.UI_DOWN_P)
			changeSelection(1);
		else if (FlxG.mouse.wheel != 0)
			changeSelection(-FlxG.mouse.wheel);

		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			close();
		}
		else if (controls.ACCEPT)
		{
			options[curSelected][1] = !options[curSelected][1];

			FlxG.sound.play(Paths.sound('scrollMenu'));
			reloadValues();
		}

		super.update(elapsed);
	}

	private function changeSelection(change:Int = 0)
	{
		curSelected += change;
		if (curSelected < 0)
			curSelected = options.length - 1;
		if (curSelected >= options.length)
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

	private function reloadValues()
	{
		for (checkbox in checkboxArray)
			checkbox.daValue = options[checkbox.ID][1];
	}
}
