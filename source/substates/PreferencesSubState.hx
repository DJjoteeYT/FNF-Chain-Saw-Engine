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
		['Ghost Tapping', 'ghostTapping', 'bool', true],
		['Downscroll', 'downScroll', 'bool', false],
		['Accuracy-Display', 'accuracyDisplay', 'bool', true],
		['Overlay', 'overlay', 'bool', false],
		['Check For Updates', 'checkForUpdates', 'bool', true],
		['Antialiasing', 'antialiasing', 'bool', true],
		['Flashing', 'flashing', 'bool', true]
	];

	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var grpTexts:FlxTypedGroup<Alphabet>;
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

		grpTexts = new FlxTypedGroup<Alphabet>();
		add(grpTexts);

		grpCheckbox = new FlxTypedGroup<CheckboxThingie>();
		add(grpCheckbox);

		for (i in 0...options.length)
		{
			var optionText:Alphabet = new Alphabet(0, 70 * i, options[i][0], false, false);
			optionText.isMenuItem = true;
			optionText.targetY = i;
			grpOptions.add(optionText);

			if (options[i][2] == 'bool')
			{
				var checkbox:CheckboxThingie = new CheckboxThingie(0, 0, false);
				checkbox.sprTracker = optionText;
				checkbox.ID = i;
				grpCheckbox.add(checkbox);
			}
			else
			{
				var valueText:AttachedAlphabet = new AttachedAlphabet(getValue(options[i][1]), optionText.width + 80);
				valueText.sprTracker = optionText;
				valueText.ID = i;
				grpTexts.add(valueText);
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
			setValue(options[curSelected][1], (getValue(options[curSelected][1]) == true) ? false : true);

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
			checkbox.daValue = getValue(options[checkbox.ID][1]);
	}

	public function getValue(variable:String):Dynamic
		return Reflect.getProperty(PreferencesData, variable);

	public function setValue(variable:String, value:Dynamic)
		Reflect.setProperty(PreferencesData, variable, value);
}
