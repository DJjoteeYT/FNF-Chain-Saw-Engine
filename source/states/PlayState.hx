package states;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;
import parsers.Song;
import parsers.Stage;
import parsers.Week;
import openfl.utils.Assets;
import substates.GameOverSubState;
import substates.PauseSubState;
import states.PlayState;

using StringTools;

class PlayState extends MusicBeatState
{
	public static var campaignScore:Int = 0;
	public static var instance:PlayState = null;
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var isPixelAssets:Bool = false;
	public static var seenCutscene:Bool = false;
	public static var deathCounter:Int = 0;
	public static var practiceMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;

	private var playerStrums:FlxTypedGroup<StrumNote> = null;
	private var opponentStrums:FlxTypedGroup<StrumNote> = null;
	private var dad:Character;
	private var gf:Character;
	private var boyfriend:Character;
	private var scriptArray:Array<ScriptCore> = [];
	private var defaultPlayerStrumX:Array<Float> = [];
	private var defaultPlayerStrumY:Array<Float> = [];
	private var defaultOpponentStrumX:Array<Float> = [];
	private var defaultOpponentStrumY:Array<Float> = [];
	private var unspawnNotes:Array<Note> = [];
	private var prevCamFollow:FlxObject;
	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;
	private var vocals:FlxSound;
	private var curSection:Int = 0;
	private var camFollow:FlxObject;
	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;
	private var score:Int = 0;
	private var scoreTxt:FlxText;
	private var defaultCamZoom:Float = 1.05;
	private var inCutscene:Bool = false;
	private var gfSpeed:Int = 1;
	private var combo:Int = 0;
	private var startTimer:FlxTimer;
	private var paused:Bool = false;
	private var startedCountdown:Bool = false;
	private var canPause:Bool = true;
	private var endingSong:Bool = false;
	private var camHUD:FlxCamera;
	private var camGame:FlxCamera;
	private var iconP1:HealthIcon;
	private var iconP2:HealthIcon;
	private var camFollowDad:Array<Float> = [0, 0];
	private var camFollowBoyfriend:Array<Float> = [0, 0];
	private var dialogue:Array<String> = ['dad:blah blah blah', 'bf:coolswag'];
	private var health:Float = 1;
	private var notes:FlxTypedGroup<Note>;
	private var strumLine:FlxSprite;

	private final divider:String = " | ";
	private final iconOffset:Int = 26;

	#if FUTURE_DISCORD_RCP
	// Discord RPC variables
	private var iconRPC:String = "";
	private var detailsText:String = "";
	#end

	override public function create()
	{
		Paths.clearStoredMemory();

		instance = this;

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		#if FUTURE_DISCORD_RCP
		iconRPC = SONG.player2;

		switch (iconRPC)
		{
			case 'senpai-angry':
				iconRPC = 'senpai';
			case 'monster-christmas':
				iconRPC = 'monster';
			case 'mom-car':
				iconRPC = 'mom';
		}

		if (isStoryMode)
			detailsText = "Story Mode: Week " + storyWeek;
		else
			detailsText = "Freeplay";

		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + CoolUtil.difficultyString(storyDifficulty) + ") " + "\nScore: " + score, iconRPC);
		#end

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		persistentUpdate = persistentDraw = true;

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		if (SONG.stage == null || SONG.stage.length < 1)
		{
			switch (SONG.song.toLowerCase())
			{
				case 'spookeez' | 'south' | 'monster':
					SONG.stage = 'spooky';
				case 'pico' | 'blammed' | 'philly':
					SONG.stage = 'philly';
				case 'milf' | 'satin-panties' | 'high':
					SONG.stage = 'limo';
				case 'cocoa' | 'eggnog':
					SONG.stage = 'mall';
				case 'winter-horrorland':
					SONG.stage = 'mallEvil';
				case 'senpai' | 'roses':
					SONG.stage = 'school';
				case 'thorns':
					SONG.stage = 'schoolEvil';
				case 'ugh' | 'guns' | 'stress':
					SONG.stage = 'tank';
				default:
					SONG.stage = 'stage';
			}
		}

		var stageFile:SwagStage = Stage.loadJson(SONG.stage);
		if (stageFile == null)
		{
			stageFile = {
				zoom: 0.9,
				gf: [400, 130],
				dad: [100, 100],
				boyfriend: [770, 100],
				camFollowDad: [150, -100],
				camFollowBoyfriend: [-100, -100]
			};
		}

		defaultCamZoom = stageFile.zoom;
		camFollowDad = stageFile.camFollowDad;
		camFollowBoyfriend = stageFile.camFollowBoyfriend;

		gf = new Character(0, 0, SONG.gfVersion);
		gf.x = stageFile.gf[0] + gf.position[0];
		gf.y = stageFile.gf[1] + gf.position[1];

		dad = new Character(0, 0, SONG.player2);
		dad.x = stageFile.dad[0] + dad.position[0];
		dad.y = stageFile.dad[1] + dad.position[1];

		boyfriend = new Character(0, 0, SONG.player1, true);
		boyfriend.x = stageFile.boyfriend[0] + boyfriend.position[0];
		boyfriend.y = stageFile.boyfriend[1] + boyfriend.position[1];

		if (Assets.exists(Paths.hx('stages/' + SONG.stage + '/script')))
			scriptArray.push(new ScriptCore(Paths.hx('stages/' + SONG.stage + '/script')));

		add(gf);
		add(dad);
		add(boyfriend);

		strumLine = new FlxSprite(0, PreferencesData.downScroll ? FlxG.height - 165 : 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

		playerStrums = new FlxTypedGroup<StrumNote>();
		add(playerStrums);

		opponentStrums = new FlxTypedGroup<StrumNote>();
		add(opponentStrums);

		generateSong(SONG.song);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.setPosition(dad.getGraphicMidpoint().x + dad.camPos[0], dad.getGraphicMidpoint().y + dad.camPos[1]);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.25);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());
		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);
		FlxG.fixedTimestep = false;

		healthBarBG = new FlxSprite(0, PreferencesData.downScroll ? FlxG.height * 0.1 : FlxG.height * 0.9).loadGraphic(Paths.image('healthBar'));
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(FlxColor.fromRGB(dad.colors[0], dad.colors[1], dad.colors[2]),
			FlxColor.fromRGB(boyfriend.colors[0], boyfriend.colors[1], boyfriend.colors[2]));
		add(healthBar);

		iconP1 = new HealthIcon(boyfriend.curCharacter, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(dad.curCharacter, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);

		scoreTxt = new FlxText(0, healthBarBG.y + 40, 0, "", 20);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 1.25;
		scoreTxt.screenCenter(X);
		add(scoreTxt);

		playerStrums.cameras = [camHUD];
		opponentStrums.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];

		#if android
		addAndroidControls(false);
		#end

		if (Assets.exists(Paths.hx('songs/' + SONG.song.toLowerCase() + '/script')))
			scriptArray.push(new ScriptCore(Paths.hx('songs/' + SONG.song.toLowerCase() + '/script')));

		startingSong = true;

		if (isStoryMode && !seenCutscene)
		{
			switch (SONG.song.toLowerCase())
			{
				case 'senpai':
					var doof:DialogueBox = new DialogueBox(false, CoolUtil.coolTextFile(Paths.txt('songs/' + SONG.song.toLowerCase() + '/dialogue')));
					doof.scrollFactor.set();
					doof.finishThing = startCountdown;
					doof.cameras = [camHUD];
					schoolIntro(doof);
				case 'roses':
					FlxG.sound.play(Paths.sound('ANGRY'));
					var doof:DialogueBox = new DialogueBox(false, CoolUtil.coolTextFile(Paths.txt('songs/' + SONG.song.toLowerCase() + '/dialogue')));
					doof.scrollFactor.set();
					doof.finishThing = startCountdown;
					doof.cameras = [camHUD];
					schoolIntro(doof);
				case 'thorns':
					var doof:DialogueBox = new DialogueBox(false, CoolUtil.coolTextFile(Paths.txt('songs/' + SONG.song.toLowerCase() + '/dialogue')));
					doof.scrollFactor.set();
					doof.finishThing = startCountdown;
					doof.cameras = [camHUD];
					schoolIntro(doof);
				default:
					startCountdown();
			}

			seenCutscene = true;
		}
		else
			startCountdown();

		super.create();

		Paths.clearUnusedMemory();
	}

	private function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('stages/weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.updateHitbox();
		senpaiEvil.scrollFactor.set();
		senpaiEvil.screenCenter();

		if (SONG.song.toLowerCase() == 'roses' || SONG.song.toLowerCase() == 'thorns')
		{
			remove(black);
			if (SONG.song.toLowerCase() == 'thorns')
				add(red);
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
				tmr.reset(0.3);
			else
			{
				if (dialogueBox != null)
				{
					inCutscene = true;

					if (SONG.song.toLowerCase() == 'thorns')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
								swagTimer.reset();
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
						add(dialogueBox);
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}

	private function startCountdown():Void
	{
		if (startedCountdown)
		{
			callScripts('startCountdown', []);
			return;
		}

		inCutscene = false;
		var ret:Dynamic = callScripts('startCountdown', []);
		if (ret != ScriptCore.Function_Stop)
		{
			#if android
			androidControls.visible = true;
			#end

			generateStaticArrows(0);
			generateStaticArrows(1);

			for (i in 0...playerStrums.length)
			{
				defaultPlayerStrumX.push(playerStrums.members[i].x);
				defaultPlayerStrumY.push(playerStrums.members[i].y);
			}

			for (i in 0...opponentStrums.length)
			{
				defaultOpponentStrumX.push(opponentStrums.members[i].x);
				defaultOpponentStrumY.push(opponentStrums.members[i].y);
			}

			startedCountdown = true;
			Conductor.songPosition = 0;
			Conductor.songPosition -= Conductor.crochet * 5;

			doIntro(Conductor.crochet / 1000);
		}
	}

	private function doIntro(startTime:Float):Void
	{
		var swagCounter:Int = 0;
		startTimer = new FlxTimer().start(startTime, function(tmr:FlxTimer)
		{
			if (tmr.loopsLeft % Math.round(gfSpeed * 2) == 0 && gf.animation.curAnim != null && !gf.animation.curAnim.name.startsWith("sing") && !gf.stunned)
				gf.dance();

			if (tmr.loopsLeft % 2 == 0 && boyfriend.animation.curAnim != null && !boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.stunned)
				boyfriend.dance();

			if (tmr.loopsLeft % 2 == 0 && dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith('sing') && !dad.stunned)
				dad.dance();

			switch (swagCounter)
			{
				case 0:
					if (!PlayState.isPixelAssets)
						FlxG.sound.play(Paths.sound('intro3'), 0.6);
					else
						FlxG.sound.play(Paths.sound('intro3-pixel'), 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite();
					if (!PlayState.isPixelAssets)
						ready.loadGraphic(Paths.image('ui/default/ready'));
					else
						ready.loadGraphic(Paths.image('ui/pixel/ready'));
					ready.scrollFactor.set();

					if (PlayState.isPixelAssets)
					{
						ready.setGraphicSize(Std.int(ready.width * 6));
						ready.updateHitbox();
					}

					ready.screenCenter();
					add(ready);

					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});

					if (!PlayState.isPixelAssets)
						FlxG.sound.play(Paths.sound('intro2'), 0.6);
					else
						FlxG.sound.play(Paths.sound('intro2-pixel'), 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite();
					if (!PlayState.isPixelAssets)
						set.loadGraphic(Paths.image('ui/default/set'));
					else
						set.loadGraphic(Paths.image('ui/pixel/set'));
					set.scrollFactor.set();

					if (PlayState.isPixelAssets)
					{
						set.setGraphicSize(Std.int(set.width * 6));
						set.updateHitbox();
					}

					set.screenCenter();
					add(set);

					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});

					if (!PlayState.isPixelAssets)
						FlxG.sound.play(Paths.sound('intro1'), 0.6);
					else
						FlxG.sound.play(Paths.sound('intro1-pixel'), 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite();
					if (!PlayState.isPixelAssets)
						go.loadGraphic(Paths.image('ui/default/go'));
					else
						go.loadGraphic(Paths.image('ui/pixel/go'));
					go.scrollFactor.set();

					if (PlayState.isPixelAssets)
					{
						go.setGraphicSize(Std.int(go.width * 6));
						go.updateHitbox();
					}

					go.screenCenter();
					add(go);

					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});

					if (!PlayState.isPixelAssets)
						FlxG.sound.play(Paths.sound('introGo'), 0.6);
					else
						FlxG.sound.play(Paths.sound('introGo-pixel'), 0.6);
			}

			swagCounter += 1;
		}, 5);
	}

	private function startSong():Void
	{
		startingSong = false;

		FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		FlxG.sound.music.onComplete = endSong;
		if (SONG.needsVoices)
			vocals.play();

		if(paused)
		{
			FlxG.sound.music.pause();
			vocals.pause();
		}

		#if FUTURE_DISCORD_RCP
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + CoolUtil.difficultyString(storyDifficulty) + ") " + "\nScore: " + score, iconRPC);
		#end
	}

	private var debugNum:Int = 0;

	private function generateSong(dataPath:String):Void
	{
		Conductor.changeBPM(SONG.bpm);

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		for (section in SONG.notes)
		{
			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];

				if (daStrumTime < 0)
					daStrumTime = 0;

				final daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
					gottaHitNote = !section.mustHitSection;

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength /= Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true);
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);

					sustainNote.mustPress = gottaHitNote;

					if (sustainNote.mustPress)
						sustainNote.x += FlxG.width / 2;
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
					swagNote.x += FlxG.width / 2;
			}
		}

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	private function sortByShit(Obj1:Note, Obj2:Note):Int
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			var babyArrow:StrumNote = new StrumNote(50, strumLine.y + 10, i, player);

			switch (player)
			{
				case 0:
					opponentStrums.add(babyArrow);
				case 1:
					playerStrums.add(babyArrow);
			}

			babyArrow.postAddedToGroup();
		}
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				if (SONG.needsVoices)
					vocals.pause();
			}

			#if FUTURE_DISCORD_RCP
			DiscordClient.changePresence("PAUSED on " + SONG.song + " (" + CoolUtil.difficultyString(storyDifficulty) + ") " + "\nScore: " + score, iconRPC);
			#end
			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);

		Paths.clearUnusedMemory();
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
				resyncVocals();

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;

			#if FUTURE_DISCORD_RCP
			DiscordClient.changePresence(detailsText
				+ " "
				+ SONG.song
				+ " ("
				+ CoolUtil.difficultyString(storyDifficulty)
				+ ") "
				+ "\nScore: "
				+ score, iconRPC, true,
				FlxG.sound.music.length
				- Conductor.songPosition);
			#end
		}

		super.closeSubState();

		Paths.clearUnusedMemory();
	}

	private function resyncVocals():Void
	{
		if (SONG.needsVoices)
			vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		if (SONG.needsVoices)
		{
			vocals.time = Conductor.songPosition;
			vocals.play();
		}

		#if FUTURE_DISCORD_RCP
		DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + CoolUtil.difficultyString(storyDifficulty) + ") " + "\nScore: " + score, iconRPC);
		#end
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		callScripts('update', [elapsed]);

		scoreTxt.text = "Score: " + score;
		scoreTxt.screenCenter(X);

		if (controls.PAUSE #if android || FlxG.android.justReleased.BACK #end && startedCountdown && canPause)
			pause();

		if (FlxG.keys.justPressed.SEVEN)
			MusicBeatState.switchState(new ChartingState());

		if (FlxG.keys.justPressed.EIGHT)
			MusicBeatState.switchState(new AnimationDebug(SONG.player2));

		if (FlxG.keys.justPressed.ZERO)
			MusicBeatState.switchState(new AnimationDebug(SONG.player1));

		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, 0.85)));
		iconP1.updateHitbox();

		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, 0.85)));
		iconP2.updateHitbox();

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if (health > 2)
			health = 2;

		iconP1.animation.curAnim.curFrame = healthBar.percent < 20 ? 1 : 0;
		iconP2.animation.curAnim.curFrame = healthBar.percent > 80 ? 1 : 0;

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			Conductor.songPosition += elapsed * 1000;

			if (!paused && Conductor.lastSongPos != Conductor.songPosition)
				Conductor.lastSongPos = Conductor.songPosition;
		}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			if (!PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
				camearaFollow('dad');
			else
				camearaFollow('bf');
		}

		if (!inCutscene && !endingSong)
		{
			//if (controls.RESET && startedCountdown)
			//{
				//health = 0;
				//trace("RESET = True");
			//}

			if (health <= 0 && !practiceMode)
				gameOver();
		}

		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 3500)
			{
				notes.add(unspawnNotes[0]);
				unspawnNotes.splice(Std.int(unspawnNotes.indexOf(unspawnNotes[0])), 1);
			}
		}

		notes.forEachAlive(function(daNote:Note)
		{
			if (generatedMusic)
				noteCalls(daNote);
		});

		if (!inCutscene && !endingSong)
			keyShit();
	}

	private function pause()
	{
		var ret:Dynamic = callScripts('pause', []);
		if (ret != ScriptCore.Function_Stop)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}
	}

	/**
	 * Jigsaw: GameOver!
	 * Adam: Aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa!
	 */
	private function gameOver()
	{
		var ret:Dynamic = callScripts('gameOver', []);
		if (ret != ScriptCore.Function_Stop)
		{
			boyfriend.stunned = true;
			persistentUpdate = persistentDraw = false;
			paused = true;

			if (SONG.needsVoices)
				vocals.stop();

			FlxG.sound.music.stop();

			deathCounter += 1;

			openSubState(new GameOverSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

			#if FUTURE_DISCORD_RCP
			// Game Over doesn't get his own variable because it's only used here
			DiscordClient.changePresence("GAME OVER -- " + SONG.song + " (" + CoolUtil.difficultyString(storyDifficulty) + ") " + "\nScore: " + score, iconRPC);
			#end
		}
	}

	private function noteCalls(daNote:Note)
	{
		if (daNote.y > FlxG.height)
		{
			daNote.active = false;
			daNote.visible = false;
		}
		else
		{
			daNote.visible = true;
			daNote.active = true;
		}

		var strumX:Float = 0;
		var strumY:Float = 0;
		var strumAngle:Float = 0;
		var strumAlpha:Float = 0;

		if (daNote.mustPress)
		{
			strumX = playerStrums.members[daNote.noteData].x;
			strumY = playerStrums.members[daNote.noteData].y;
			strumAngle = playerStrums.members[daNote.noteData].angle;
			strumAlpha = playerStrums.members[daNote.noteData].alpha;
		}
		else
		{
			strumX = opponentStrums.members[daNote.noteData].x;
			strumY = opponentStrums.members[daNote.noteData].y;
			strumAngle = opponentStrums.members[daNote.noteData].angle;
			strumAlpha = opponentStrums.members[daNote.noteData].alpha;
		}

		strumX += daNote.offsetX;
		strumY += daNote.offsetY;
		strumAngle += daNote.offsetAngle;
		strumAlpha *= daNote.multAlpha;

		daNote.x = strumX;
		daNote.angle = strumAngle;
		daNote.alpha = strumAlpha;

		var center:Float = strumY + (Note.swagWidth / 2);

		// i am so fucking sorry for these if conditions
		if (PreferencesData.downScroll)
		{
			daNote.y = strumY + 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(SONG.speed, 2);

			if (daNote.sustainNote)
			{
				daNote.flipY = true;

				// https://github.com/KadeDev/Vs-Zardy/blob/main/source/PlayState.hx line 3083
				daNote.y -= daNote.height - (0.45 * Conductor.stepCrochet * FlxMath.roundDecimal(PlayState.SONG.speed, 2));

				if (daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center
					&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
				{
					var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
					swagRect.height = (center - daNote.y) / daNote.scale.y;
					swagRect.y = daNote.frameHeight - swagRect.height;

					daNote.clipRect = swagRect;
				}
			}
		}
		else
		{
			daNote.y = strumY - 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(SONG.speed, 2);

			if (daNote.sustainNote
				&& daNote.y + daNote.offset.y * daNote.scale.y <= center
				&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
			{
				var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
				swagRect.y = (center - daNote.y) / daNote.scale.y;
				swagRect.height -= swagRect.y;

				daNote.clipRect = swagRect;
			}
		}

		if (!daNote.mustPress && daNote.wasGoodHit)
			opponentNoteHit(daNote);

		var doKill = daNote.y < -daNote.height;
		if (PreferencesData.downScroll)
			doKill = daNote.y > FlxG.height;

		if (doKill)
		{
			if (daNote.tooLate || !daNote.wasGoodHit)
			{
				health -= 0.0475;
				vocals.volume = 0;
			}

			daNote.active = false;
			daNote.visible = false;

			destroyNote(daNote);
		}
	}

	private function destroyNote(daNote:Note)
	{
		daNote.kill();
		notes.remove(daNote, true);
		daNote.destroy();
	}

	private function camearaFollow(character:String)
	{
		switch (character)
		{
			case 'dad':
				camFollow.x = dad.getMidpoint().x + camFollowDad[0];
				camFollow.y = dad.getMidpoint().y + camFollowDad[1];
			default:
				camFollow.x = boyfriend.getMidpoint().x + camFollowBoyfriend[0];
				camFollow.y = boyfriend.getMidpoint().y + camFollowBoyfriend[1];
		}

		callScripts('camearaFollow', [character]);
	}

	private function endSong():Void
	{
		seenCutscene = false;
		canPause = false;
		FlxG.sound.music.volume = vocals.volume = 0;

		#if android
		androidControls.visible = false;
		#end

		var ret:Dynamic = callScripts('endSong', []);
		if (ret != ScriptCore.Function_Stop)
		{
			if (SONG.validScore)
				HighScore.saveScore(SONG.song, Math.round(score), storyDifficulty);

			if (isStoryMode)
			{
				campaignScore += Math.round(score);

				storyPlaylist.remove(storyPlaylist[0]);

				if (storyPlaylist.length <= 0)
				{
					FlxG.sound.playMusic(Paths.music('freakyMenu'));

					MusicBeatState.switchState(new StoryMenuState());

					StoryMenuState.weekUnlocked[Std.int(Math.min(storyWeek + 1, StoryMenuState.weekUnlocked.length - 1))] = true;

					if (SONG.validScore)
						HighScore.saveWeekScore(Week.weeksList[storyWeek], campaignScore, storyDifficulty);
				}
				else
				{
					FlxTransitionableState.skipNextTransIn = FlxTransitionableState.skipNextTransOut = true;
					prevCamFollow = camFollow;

					PlayState.SONG = Song.loadJson(HighScore.formatSong(PlayState.storyPlaylist[0].toLowerCase(), storyDifficulty), PlayState.storyPlaylist[0]);
					FlxG.sound.music.stop();
					MusicBeatState.switchState(new PlayState());
				}
			}
			else
			{
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
				MusicBeatState.switchState(new FreeplayState());
			}
		}
	}

	private function popUpScore(daNote:Note):Void
	{
		var noteDiff:Float = Math.abs(daNote.strumTime - Conductor.songPosition);
		vocals.volume = 1;

		var addedScore:Int = 350;
		var daRating:String = "sick";

		if (noteDiff > Conductor.safeZoneOffset * 0.9)
		{
			daRating = 'shit';
			addedScore = 50;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.75)
		{
			daRating = 'bad';
			addedScore = 100;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.2)
		{
			daRating = 'good';
			addedScore = 200;
		}

		if (!practiceMode)
			score += addedScore;

		var rating:FlxSprite = new FlxSprite(-40, -60);
		if (!PlayState.isPixelAssets)
			rating.loadGraphic(Paths.image('ui/default/' + daRating));
		else
			rating.loadGraphic(Paths.image('ui/pixel/' + daRating));
		rating.screenCenter();
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);

		if (!PlayState.isPixelAssets)
			rating.setGraphicSize(Std.int(rating.width * 0.7));
		else
			rating.setGraphicSize(Std.int(rating.width * 6 * 0.7));

		rating.updateHitbox();
		rating.cameras = [camHUD];
		add(rating);

		var comboSpr:FlxSprite = new FlxSprite();
		if (!PlayState.isPixelAssets)
			comboSpr.loadGraphic(Paths.image('ui/default/combo'));
		else
			comboSpr.loadGraphic(Paths.image('ui/pixel/combo'));
		comboSpr.screenCenter();
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;
		comboSpr.velocity.x += FlxG.random.int(1, 10);

		if (!PlayState.isPixelAssets)
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
		else
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 6 * 0.7));

		comboSpr.updateHitbox();
		comboSpr.cameras = [camHUD];
		add(comboSpr);

		var seperatedScore:Array<Int> = [];
		seperatedScore.push(Math.floor(combo / 100));
		seperatedScore.push(Math.floor((combo - (seperatedScore[0] * 100)) / 10));
		seperatedScore.push(combo % 10);

		var daLoop:Int = 0;
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite();
			if (!PlayState.isPixelAssets)
				numScore.loadGraphic(Paths.image('ui/default/num' + Std.int(i)));
			else
				numScore.loadGraphic(Paths.image('ui/pixel/num' + Std.int(i)));
			numScore.screenCenter();
			numScore.x = (43 * daLoop) - 90;
			numScore.y += 80;
			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.velocity.y -= FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);

			if (!PlayState.isPixelAssets)
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			else
				numScore.setGraphicSize(Std.int(numScore.width * 6));

			numScore.updateHitbox();
			numScore.cameras = [camHUD];
			if (combo >= 10 || combo == 0)
				add(numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002
			});

			daLoop++;
		}

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				comboSpr.destroy();
				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.001
		});

		curSection += 1;
	}

	public function NearlyEquals(value1:Float, value2:Float, unimportantDifference:Float = 10):Bool
		return Math.abs(FlxMath.roundDecimal(value1, 1) - FlxMath.roundDecimal(value2, 1)) < unimportantDifference;

	private function keyShit():Void
	{
		var holdingArray:Array<Bool> = [controls.NOTE_LEFT, controls.NOTE_DOWN, controls.NOTE_UP, controls.NOTE_RIGHT];
		var controlArray:Array<Bool> = [
			controls.NOTE_LEFT_P,
			controls.NOTE_DOWN_P,
			controls.NOTE_UP_P,
			controls.NOTE_RIGHT_P
		];
		var releaseArray:Array<Bool> = [
			controls.NOTE_LEFT_R,
			controls.NOTE_DOWN_R,
			controls.NOTE_UP_R,
			controls.NOTE_RIGHT_R
		];

		if (holdingArray.contains(true) && generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.sustainNote && daNote.canBeHit && daNote.mustPress && holdingArray[daNote.noteData])
					goodNoteHit(daNote);
			});
		}

		if (controlArray.contains(true) && generatedMusic)
		{
			boyfriend.holdTimer = 0;

			var possibleNotes:Array<Note> = [];
			var ignoreList:Array<Int> = [];
			var removeList:Array<Note> = [];

			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit)
				{
					if (ignoreList.contains(daNote.noteData))
					{
						for (possibleNote in possibleNotes)
						{
							if (possibleNote.noteData == daNote.noteData && Math.abs(daNote.strumTime - possibleNote.strumTime) < 10)
							{
								removeList.push(daNote);
							}
							else if (possibleNote.noteData == daNote.noteData && daNote.strumTime < possibleNote.strumTime)
							{
								possibleNotes.remove(possibleNote);
								possibleNotes.push(daNote);
							}
						}
					}
					else
					{
						possibleNotes.push(daNote);
						ignoreList.push(daNote.noteData);
					}
				}
			});

			for (badNote in removeList)
			{
				badNote.kill();
				notes.remove(badNote, true);
				badNote.destroy();
			}

			possibleNotes.sort(function(note1:Note, note2:Note)
			{
				return Std.int(note1.strumTime - note2.strumTime);
			});

			if (possibleNotes.length > 0)
			{
				if (!PreferencesData.ghostTapping)
				{
					for (i in 0...controlArray.length)
						if (controlArray[i] && !ignoreList.contains(i))
							noteMiss(controlArray[i], i);
				}

				for (possibleNote in possibleNotes)
					if (controlArray[possibleNote.noteData])
						goodNoteHit(possibleNote);
			}
			else if (!PreferencesData.ghostTapping)
			{
				for (i in 0...controlArray.length)
					noteMiss(controlArray[i], i);
			}
		}

		if (boyfriend.animation.curAnim != null && boyfriend.holdTimer > Conductor.stepCrochet * 0.001 * boyfriend.singDuration
			&& boyfriend.animation.curAnim.name.startsWith('sing')
			&& !boyfriend.animation.curAnim.name.endsWith('miss'))
			boyfriend.dance();

		playerStrums.forEach(function(spr:StrumNote)
		{
			if (controlArray[spr.ID] && spr.animation.curAnim.name != 'confirm')
				spr.playAnim('pressed');

			if (releaseArray[spr.ID])
				spr.playAnim('static');
		});
	}

	private function noteMiss(statement:Bool = false, direction:Int = 0)
	{
		if (statement && !boyfriend.stunned)
		{
			health -= 0.04;
			if (combo > 5 && gf.animOffsets.exists('sad'))
				gf.playAnim('sad');

			combo = 0;

			if (!practiceMode)
				score -= 10;

			FlxG.sound.play(Paths.sound('missnote' + FlxG.random.int(1, 3)), FlxG.random.float(0.1, 0.2));

			switch (Math.abs(direction) % 4)
			{
				case 0:
					boyfriend.playAnim('singRIGHTmiss', true);
				case 1:
					boyfriend.playAnim('singDOWNmiss', true);
				case 2:
					boyfriend.playAnim('singUPmiss', true);
				case 3:
					boyfriend.playAnim('singLEFTmiss', true);
			}

			vocals.volume = 0;
		}
	}

	private function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			if (!note.sustainNote)
			{
				popUpScore(note);
				combo += 1;
			}

			if (note.noteData >= 0)
				health += 0.023;
			else
				health += 0.004;

			switch (Math.abs(note.noteData) % 4)
			{
				case 0:
					boyfriend.playAnim('singRIGHT', true);
				case 1:
					boyfriend.playAnim('singDOWN', true);
				case 2:
					boyfriend.playAnim('singUP', true);
				case 3:
					boyfriend.playAnim('singLEFT', true);
			}

			playerStrums.forEach(function(spr:StrumNote)
			{
				if (Math.abs(note.noteData) == spr.ID)
					spr.playAnim('confirm', true);
			});

			note.wasGoodHit = true;

			if (SONG.needsVoices)
				vocals.volume = 1;

			if (!note.sustainNote)
				destroyNote(note);
		}
	}

	private function opponentNoteHit(note:Note):Void
	{
		var altAnim:String = "";

		if (SONG.notes[Math.floor(curStep / 16)] != null && SONG.notes[Math.floor(curStep / 16)].altAnim)
			altAnim = '-alt';

		switch (Math.abs(note.noteData) % 4)
		{
			case 0:
				dad.playAnim('singLEFT' + altAnim, true);
			case 1:
				dad.playAnim('singDOWN' + altAnim, true);
			case 2:
				dad.playAnim('singUP' + altAnim, true);
			case 3:
				dad.playAnim('singRIGHT' + altAnim, true);
		}

		opponentStrums.forEach(function(spr:StrumNote)
		{
			if (Math.abs(note.noteData) == spr.ID)
				spr.playAnim('confirm', true);
		});

		dad.holdTimer = 0;

		if (SONG.needsVoices)
			vocals.volume = 1;

		if (!note.sustainNote)
			destroyNote(note);
	}

	private var danced:Bool = false;

	override function stepHit()
	{
		super.stepHit();

		callScripts('stepHit', [curStep]);

		if (Math.abs(FlxG.sound.music.time - (Conductor.songPosition - Conductor.offset)) > 20
			|| (SONG.needsVoices && Math.abs(vocals.time - (Conductor.songPosition - Conductor.offset)) > 20))
			resyncVocals();

		#if FUTURE_DISCORD_RCP
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText
			+ " "
			+ SONG.song
			+ " ("
			+ CoolUtil.difficultyString(storyDifficulty)
			+ ") "
			+ "\nScore: "
			+ score, iconRPC, true,
			FlxG.sound.music.length
			- Conductor.songPosition);
		#end
	}

	override function beatHit()
	{
		super.beatHit();

		callScripts('beatHit', [curBeat]);

		if (generatedMusic)
			notes.sort(FlxSort.byY, (PreferencesData.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING));

		iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		iconP1.updateHitbox();

		iconP2.setGraphicSize(Std.int(iconP2.width + 30));
		iconP2.updateHitbox();

		if (curBeat % Math.round(gfSpeed * 2) == 0 && gf.animation.curAnim != null && !gf.animation.curAnim.name.startsWith("sing") && !gf.stunned)
			gf.dance();

		if (curBeat % 2 == 0 && boyfriend.animation.curAnim != null && !boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.stunned)
			boyfriend.dance();

		if (curBeat % 2 == 0 && dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith('sing') && !dad.stunned)
			dad.dance();
	}

	override function destroy()
	{
		scriptArray = [];
		defaultPlayerStrumX = [];
		defaultPlayerStrumY = [];
		defaultOpponentStrumX = [];
		defaultOpponentStrumY = [];

		super.destroy();
	}

	private function callScripts(funcName:String, args:Array<Dynamic>):Dynamic
	{
		var value:Dynamic = ScriptCore.Function_Continue;

		for (i in 0...scriptArray.length)
		{
			final call:Dynamic = scriptArray[i].executeFunc(funcName, args);
			final bool:Bool = call == ScriptCore.Function_Continue;
			if (!bool && call != null)
				value = call;
		}

		return value;
	}

	private function setScripts(name:String, val:Dynamic)
		for (i in 0...scriptArray.length)
			scriptArray[i].setVariable(name, val);
}
