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
		['Ghost Tapping', 'bool'],
		['Downscroll', 'bool'],
		['Accuracy-Display', 'bool'],
		['Overlay', 'bool'],
		['Check For Updates', 'bool'],
		['Auto-Play', 'bool'],
		['Antialiasing', 'bool'],
		['Flashing', 'bool']
	];

	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var grpCheckbox:FlxTypedGroup<CheckboxThingie>;

	public function new()
	{
		super();

		#if FUTURE_DISCORD_RCP
		DiscordClient.changePresence("Preferences Menu", null);
		#end

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.color = 0xFFea71fd;
		bg.screenCenter();
		add(bg);

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		grpCheckbox = new FlxTypedGroup<CheckboxThingie>();
		add(grpCheckbox);

		for (i in 0...options.length)
		{
			var optionText:Alphabet = new Alphabet(0, 70 * i, options[i][0], false, false);
			optionText.isMenuItem = true;
			optionText.targetY = i;
			grpOptions.add(optionText);

			if (options[i][1] == 'bool')
			{
				var checkbox:CheckboxThingie = new CheckboxThingie(0, 20, false);
				checkbox.sprTracker = optionText;
				checkbox.ID = i;
				grpCheckbox.add(checkbox);
			}
		}

		changeSelection();
		reloadValues();

		#if android
		addVirtualPad(UP_DOWN, A_B);
		addPadCamera(false);
		#end
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
			PreferencesData.write();

			flixel.addons.transition.FlxTransitionableState.skipNextTransOut = true;
			FlxG.resetState();

			FlxG.sound.play(Paths.sound('cancelMenu'));
		}
		else if (controls.ACCEPT)
		{
			switch (options[curSelected][0])
			{
				case 'Ghost Tapping':
					PreferencesData.ghostTapping = !PreferencesData.ghostTapping;
				case 'Downscroll':
					PreferencesData.downScroll = !PreferencesData.downScroll;
				case 'Accuracy-Display':
					PreferencesData.accuracyDisplay = !PreferencesData.accuracyDisplay;
				case 'Overlay':
					PreferencesData.overlay = !PreferencesData.overlay;
				case 'Check For Updates':
					PreferencesData.checkForUpdates = !PreferencesData.checkForUpdates;
				case 'Auto-Play':
					PreferencesData.autoPlay = !PreferencesData.autoPlay;
				case 'Antialiasing':
					PreferencesData.antialiasing = !PreferencesData.antialiasing;
				case 'Flashing':
					PreferencesData.antialiasing = !PreferencesData.antialiasing;
			}

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

	private function reloadValues()
	{
		for (checkbox in grpCheckbox.members)
		{
			switch (options[checkbox.ID][0])
			{
				case 'Ghost Tapping':
					checkbox.daValue = PreferencesData.ghostTapping;
				case 'Downscroll':
					checkbox.daValue = PreferencesData.downScroll;
				case 'Accuracy-Display':
					checkbox.daValue = PreferencesData.accuracyDisplay;
				case 'Overlay':
					checkbox.daValue = PreferencesData.overlay;
				case 'Check For Updates':
					checkbox.daValue = PreferencesData.checkForUpdates;
				case 'Auto-Play':
					checkbox.daValue = PreferencesData.autoPlay;
				case 'Antialiasing':
					checkbox.daValue = PreferencesData.antialiasing;
				case 'Flashing':
					checkbox.daValue = PreferencesData.antialiasing;
			}
		}
	}
}
