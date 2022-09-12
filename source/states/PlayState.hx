package states;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.effects.FlxTrail;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
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
import parsers.Stage.SwagStage;
import openfl.utils.Assets;
import substates.GameOverSubState;
import substates.PauseSubState;
import states.PlayState;

using StringTools;

class PlayState extends MusicBeatState
{
	public static var misses:Int = 0;
	public static var campaignScore:Int = 0;
	public static var daPixelZoom:Float = 6;
	public static var instance:PlayState = null;
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var shits:Int = 0;
	public static var bads:Int = 0;
	public static var goods:Int = 0;
	public static var sicks:Int = 0;
	public static var songPosBG:FlxSprite;
	public static var songPosBar:FlxBar;

	public static var playerStrums:FlxTypedGroup<StrumNote> = null;
	public static var opponentStrums:FlxTypedGroup<StrumNote> = null;

	public static var defaultPlayerStrumX:Array<Float> = [];
	public static var defaultPlayerStrumY:Array<Float> = [];
	public static var defaultOpponentStrumX:Array<Float> = [];
	public static var defaultOpponentStrumY:Array<Float> = [];

	public static var dad:Character;
	public static var gf:Character;
	public static var boyfriend:Character;
	public static var songRate = 1.5;
	public static var scriptArray:Array<Script> = [];

	private var prevCamFollow:FlxObject;
	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;
	private var songLength:Float = 0;
	private var vocals:FlxSound;
	private var unspawnNotes:Array<Note> = [];
	private var curSection:Int = 0;
	private var camFollow:FlxObject;
	private var accuracy:Float = 0.00;
	private var accuracyDefault:Float = 0.00;
	private var totalNotesHit:Float = 0;
	private var totalNotesHitDefault:Float = 0;
	private var totalPlayed:Int = 0;
	private var songPositionBar:Float = 0;
	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;
	private var camGame:FlxCamera;
	private var currentFrames:Int = 0;
	private var trainSound:FlxSound;
	private var songName:FlxText;
	private var bgGirls:BackgroundGirls;
	private var talking:Bool = true;
	private var score:Int = 0;
	private var scoreTxt:FlxText;
	private var defaultCamZoom:Float = 1.05;
	private var inCutscene:Bool = false;
	private var triggeredAlready:Bool = false;
	private var camZooming:Bool = false;
	private var curSong:String = "";
	private var gfSpeed:Int = 1;
	private var combo:Int = 0;
	private var curLight:Int = 0;
	private var startTimer:FlxTimer;
	private var previousFrameTime:Int = 0;
	private var lastReportedPlayheadPosition:Int = 0;
	private var songTime:Float = 0;
	private var songStarted = false;
	private var paused:Bool = false;
	private var startedCountdown:Bool = false;
	private var canPause:Bool = true;
	private var endingSong:Bool = false;
	private var hits:Array<Float> = [];
	private var offsetTest:Float = 0;
	private final divider:String = " | ";
	private final iconOffset:Int = 26;

	#if desktop
	// Discord RPC variables
	private var storyDifficultyText:String = "";
	private var iconRPC:String = "";
	private var detailsText:String = "";
	private var detailsPausedText:String = "";
	#end

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var camHUD:FlxCamera;
	public var camPosGirlfriend:Array<Float> = [0, 0];
	public var camPosDad:Array<Float> = [0, 0];
	public var camPosBoyfriend:Array<Float> = [0, 0];
	public var dialogue:Array<String> = ['dad:blah blah blah', 'bf:coolswag'];
	public var health:Float = 1;
	public var notes:FlxTypedGroup<Note>;
	public var strumLine:FlxSprite;

	override public function create()
	{
		Paths.clearStoredMemory();

		instance = this;

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		sicks = 0;
		bads = 0;
		shits = 0;
		goods = 0;
		misses = 0;

		#if desktop
		// Making difficulty text for Discord Rich Presence.
		switch (storyDifficulty)
		{
			case 0:
				storyDifficultyText = "Easy";
			case 1:
				storyDifficultyText = "Normal";
			case 2:
				storyDifficultyText = "Hard";
		}

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
		{
			detailsText = "Story Mode: Week " + storyWeek;
		}
		else
		{
			detailsText = "Freeplay";
		}

		detailsPausedText = "Paused - " + detailsText;

		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText
			+ " "
			+ SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ Ratings.GenerateLetterRank(accuracy),
			"\nAcc: "
			+ CoolUtil.truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ score
			+ " | Misses: "
			+ misses, iconRPC);
		#end

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);

		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		persistentUpdate = persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		trace('INFORMATION ABOUT WHAT U PLAYIN WIT:\nFRAMES: ' + Conductor.safeFrames + '\nZONE: ' + Conductor.safeZoneOffset + '\nTS: '
			+ Conductor.timeScale + '\nBotPlay : ' + FlxG.save.data.botplay);

		if (SONG.stage == null || SONG.stage.length < 1)
		{
			switch (curSong.toLowerCase())
			{
				case 'spookeez' | 'south' | 'monster':
					SONG.stage = 'spooky';
				case 'pico' | 'blammed' | 'philly' | 'philly-nice':
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
				suffix: "",
				zoom: 0.9,
				girlfriend: [400, 130],
				dad: [100, 100],
				boyfriend: [770, 450],
				camPosGirlfriend: [0, 0],
				camPosDad: [0, 0],
				camPosBoyfriend: [0, 0]
			};
		}

		defaultCamZoom = stageFile.zoom;
		gf = new Character(stageFile.girlfriend[0], stageFile.girlfriend[1], SONG.gfVersion);
		dad = new Character(stageFile.dad[0], stageFile.dad[1], SONG.player2);
		boyfriend = new Character(stageFile.boyfriend[0], stageFile.boyfriend[1], SONG.player1, true);

		camPosGirlfriend = stageFile.camPosGirlfriend;
		camPosDad = stageFile.camPosDad;
		camPosBoyfriend = stageFile.camPosBoyfriend;

		switch (SONG.stage)
		{
			case 'school':
				var bgSky = new FlxSprite().loadGraphic(Paths.image('stages/weeb/weebSky'));
				bgSky.scrollFactor.set(0.1, 0.1);
				add(bgSky);

				var repositionShit = -200;

				var bgSchool:FlxSprite = new FlxSprite(repositionShit, 0).loadGraphic(Paths.image('stages/weeb/weebSchool'));
				bgSchool.scrollFactor.set(0.6, 0.90);
				add(bgSchool);

				var bgStreet:FlxSprite = new FlxSprite(repositionShit).loadGraphic(Paths.image('stages/weeb/weebStreet'));
				bgStreet.scrollFactor.set(0.95, 0.95);
				add(bgStreet);

				var fgTrees:FlxSprite = new FlxSprite(repositionShit + 170, 130).loadGraphic(Paths.image('stages/weeb/weebTreesBack'));
				fgTrees.scrollFactor.set(0.9, 0.9);
				add(fgTrees);

				var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
				bgTrees.frames = Paths.getPackerAtlas('stages/weeb/weebTrees');
				bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
				bgTrees.animation.play('treeLoop');
				bgTrees.scrollFactor.set(0.85, 0.85);
				add(bgTrees);

				var treeLeaves:FlxSprite = new FlxSprite(repositionShit, -40);
				treeLeaves.frames = Paths.getSparrowAtlas('stages/weeb/petals');
				treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
				treeLeaves.animation.play('leaves');
				treeLeaves.scrollFactor.set(0.85, 0.85);
				add(treeLeaves);

				var widShit = Std.int(bgSky.width * 6);

				bgSky.setGraphicSize(widShit);
				bgSchool.setGraphicSize(widShit);
				bgStreet.setGraphicSize(widShit);
				bgTrees.setGraphicSize(Std.int(widShit * 1.4));
				fgTrees.setGraphicSize(Std.int(widShit * 0.8));
				treeLeaves.setGraphicSize(widShit);

				fgTrees.updateHitbox();
				bgSky.updateHitbox();
				bgSchool.updateHitbox();
				bgStreet.updateHitbox();
				bgTrees.updateHitbox();
				treeLeaves.updateHitbox();

				bgGirls = new BackgroundGirls(-100, 190);
				bgGirls.scrollFactor.set(0.9, 0.9);

				if (SONG.song.toLowerCase() == 'roses' && FlxG.save.data.distractions)
					bgGirls.getScared();

				bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
				bgGirls.updateHitbox();
				add(bgGirls);
			default:
				if (Assets.exists(Paths.hx('stages/' + SONG.stage + '/script')))
					scriptArray.push(new Script(Assets.getText(Paths.hx('stages/' + SONG.stage + '/script'))));
		}

		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		switch (SONG.player2)
		{
			case 'gf':
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
				if (isStoryMode)
				{
					camPos.x += 600;
					tweenCamIn();
				}

			case "spooky":
				dad.y += 200;
			case "monster":
				dad.y += 100;
			case 'monster-christmas':
				dad.y += 130;
			case 'dad':
				camPos.x += 400;
			case 'pico':
				camPos.x += 600;
				dad.y += 300;
			case 'parents-christmas':
				dad.x -= 500;
			case 'senpai':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'senpai-angry':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'spirit':
				dad.x -= 150;
				dad.y += 100;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
		}

		switch (SONG.stage)
		{
			case 'schoolEvil':
				if (FlxG.save.data.distractions)
					add(new FlxTrail(dad, null, 4, 24, 0.3, 0.069));
		}

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

		camFollow.setPosition(camPos.x, camPos.y);

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
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		add(healthBar);

		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(SONG.player2, false);
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

		if (Assets.exists(Paths.hx('songs/' + curSong.toLowerCase() + '/script')))
			scriptArray.push(new Script(Assets.getText(Paths.hx('songs/' + curSong.toLowerCase() + '/script'))));

		startingSong = true;

		if (isStoryMode)
		{
			switch (curSong.toLowerCase())
			{
				case "winter-horrorland":
					var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					camHUD.visible = false;

					new FlxTimer().start(0.1, function(tmr:FlxTimer)
					{
						remove(blackScreen);
						FlxG.sound.play(Paths.sound('Lights_Turn_On'));
						camFollow.y = -2050;
						camFollow.x += 200;
						FlxG.camera.focusOn(camFollow.getPosition());
						FlxG.camera.zoom = 1.5;

						new FlxTimer().start(0.8, function(tmr:FlxTimer)
						{
							camHUD.visible = true;
							remove(blackScreen);
							FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
								ease: FlxEase.quadInOut,
								onComplete: function(twn:FlxTween)
								{
									startCountdown();
								}
							});
						});
					});
				case 'senpai':
					var doof:DialogueBox = new DialogueBox(false, CoolUtil.coolTextFile(Paths.txt('data/senpai/senpaiDialogue')));
					doof.scrollFactor.set();
					doof.finishThing = startCountdown;
					doof.cameras = [camHUD];
					schoolIntro(doof);
				case 'roses':
					FlxG.sound.play(Paths.sound('ANGRY'));
					var doof:DialogueBox = new DialogueBox(false, CoolUtil.coolTextFile(Paths.txt('data/roses/rosesDialogue')));
					doof.scrollFactor.set();
					doof.finishThing = startCountdown;
					doof.cameras = [camHUD];
					schoolIntro(doof);
				case 'thorns':
					var doof:DialogueBox = new DialogueBox(false, CoolUtil.coolTextFile(Paths.txt('data/thorns/thornsDialogue')));
					doof.scrollFactor.set();
					doof.finishThing = startCountdown;
					doof.cameras = [camHUD];
					schoolIntro(doof);
				default:
					startCountdown();
			}
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
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();

		if (SONG.song.toLowerCase() == 'roses' || SONG.song.toLowerCase() == 'thorns')
		{
			remove(black);

			if (SONG.song.toLowerCase() == 'thorns')
			{
				add(red);
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
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
							{
								swagTimer.reset();
							}
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
					{
						add(dialogueBox);
					}
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}

	private function startCountdown():Void
	{
		inCutscene = false;

		generateStaticArrows(0);
		generateStaticArrows(1);

		defaultPlayerStrumX = [];
		defaultPlayerStrumY = [];
		defaultOpponentStrumX = [];
		defaultOpponentStrumY = [];

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

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			dad.dance();
			gf.dance();
			boyfriend.dance();

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', "set", "go"]);
			introAssets.set('school', [
				'stages/weeb/pixelUI/ready-pixel',
				'stages/weeb/pixelUI/set-pixel',
				'stages/weeb/pixelUI/date-pixel'
			]);
			introAssets.set('schoolEvil', [
				'stages/weeb/pixelUI/ready-pixel',
				'stages/weeb/pixelUI/set-pixel',
				'stages/weeb/pixelUI/date-pixel'
			]);

			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";

			for (value in introAssets.keys())
			{
				if (value == SONG.stage)
				{
					introAlts = introAssets.get(value);
					altSuffix = '-pixel';
				}
			}

			switch (swagCounter)
			{
				case 0:
					FlxG.sound.play(Paths.sound('intro3' + altSuffix), 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					ready.scrollFactor.set();
					ready.updateHitbox();

					if (SONG.stage.startsWith('school'))
						ready.setGraphicSize(Std.int(ready.width * daPixelZoom));

					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro2' + altSuffix), 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					set.scrollFactor.set();

					if (SONG.stage.startsWith('school'))
						set.setGraphicSize(Std.int(set.width * daPixelZoom));

					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro1' + altSuffix), 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					go.scrollFactor.set();

					if (SONG.stage.startsWith('school'))
						go.setGraphicSize(Std.int(go.width * daPixelZoom));

					go.updateHitbox();

					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('introGo' + altSuffix), 0.6);
			}

			swagCounter += 1;
		}, 5);
	}

	private function startSong():Void
	{
		startingSong = false;
		songStarted = true;
		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!paused)
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);

		FlxG.sound.music.onComplete = endSong;

		if (SONG.needsVoices)
			vocals.play();

		#if desktop
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText
			+ " "
			+ SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ Ratings.GenerateLetterRank(accuracy),
			"\nAcc: "
			+ CoolUtil.truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ score
			+ " | Misses: "
			+ misses, iconRPC);
		#end
	}

	private var debugNum:Int = 0;

	private function generateSong(dataPath:String):Void
	{
		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		for (section in noteData)
		{
			var coolSection:Int = Std.int(section.lengthInSteps / 4);

			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0] + FlxG.save.data.offset;
				if (daStrumTime < 0)
					daStrumTime = 0;
				var daNoteData:Int = Std.int(songNotes[1] % 4);

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
						sustainNote.x += FlxG.width / 2; // general offset
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
					swagNote.x += FlxG.width / 2; // general offset
			}
			daBeats += 1;
		}

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	private function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

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

	private function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
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

			#if desktop
			DiscordClient.changePresence("PAUSED on "
				+ SONG.song
				+ " ("
				+ storyDifficultyText
				+ ") "
				+ Ratings.GenerateLetterRank(accuracy),
				"Acc: "
				+ CoolUtil.truncateFloat(accuracy, 2)
				+ "% | Score: "
				+ score
				+ " | Misses: "
				+ misses, iconRPC);
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
			{
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;

			#if desktop
			if (startTimer.finished)
			{
				DiscordClient.changePresence(detailsText
					+ " "
					+ SONG.song
					+ " ("
					+ storyDifficultyText
					+ ") "
					+ Ratings.GenerateLetterRank(accuracy),
					"\nAcc: "
					+ CoolUtil.truncateFloat(accuracy, 2)
					+ "% | Score: "
					+ score
					+ " | Misses: "
					+ misses, iconRPC, true,
					songLength
					- Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ") " + Ratings.GenerateLetterRank(accuracy), iconRPC);
			}
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

		#if desktop
		DiscordClient.changePresence(detailsText
			+ " "
			+ SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ Ratings.GenerateLetterRank(accuracy),
			"\nAcc: "
			+ CoolUtil.truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ score
			+ " | Misses: "
			+ misses, iconRPC);
		#end
	}

	override public function update(elapsed:Float)
	{
		if (FlxG.save.data.botplay && FlxG.keys.justPressed.ONE)
			camHUD.visible = !camHUD.visible;

		callScripts('update', [elapsed]);

		super.update(elapsed);

		scoreTxt.screenCenter(X);
		if (!FlxG.save.data.accuracyDisplay)
			scoreTxt.text = "Score: " + score;
		else
		{
			if (Ratings.GenerateLetterRank(accuracy) != '?')
				scoreTxt.text = "Score: " + score + divider + "Combo Breaks: " + misses + divider + "Accuracy: " + CoolUtil.truncateFloat(accuracy, 2) + " - "
					+ Ratings.GenerateLetterRank(accuracy);
			else
				scoreTxt.text = "Score: " + score + divider + "Combo Breaks: " + misses + divider + "Accuracy: " + Ratings.GenerateLetterRank(accuracy);
		}

		if (controls.PAUSE && startedCountdown && canPause)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}

		if (FlxG.keys.justPressed.SEVEN)
			MusicBeatState.switchState(new ChartingState());

		if (FlxG.keys.justPressed.EIGHT)
			MusicBeatState.switchState(new AnimationDebug(SONG.player2));

		if (FlxG.keys.justPressed.ZERO)
			MusicBeatState.switchState(new AnimationDebug(SONG.player1));

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
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			Conductor.songPosition += FlxG.elapsed * 1000;
			songPositionBar = Conductor.songPosition;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
				}
			}
		}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			// Make sure Girlfriend cheers only for certain songs
			if (curSong == 'Bopeebo' || curSong == 'Philly' || curSong == 'Blammed' || curSong == 'Cocoa' || curSong == 'Eggnog')
			{
				// Don't animate GF if something else is already animating her (eg. train passing)
				if (gf.animation.curAnim.name == 'danceLeft'
					|| gf.animation.curAnim.name == 'danceRight'
					|| gf.animation.curAnim.name == 'idle')
				{
					// Per song treatment since some songs will only have the 'Hey' at certain times
					switch (curSong)
					{
						case 'Philly':
							{
								// General duration of the song
								if (curBeat < 250)
								{
									// Beats to skip or to stop GF from cheering
									if (curBeat != 184 && curBeat != 216)
									{
										if (curBeat % 16 == 8)
										{
											// Just a garantee that it'll trigger just once
											if (!triggeredAlready)
											{
												gf.playAnim('cheer');
												triggeredAlready = true;
											}
										}
										else
											triggeredAlready = false;
									}
								}
							}
						case 'Bopeebo':
							{
								// Where it starts || where it ends
								if (curBeat > 5 && curBeat < 130)
								{
									if (curBeat % 8 == 7)
									{
										if (!triggeredAlready)
										{
											gf.playAnim('cheer');
											triggeredAlready = true;
										}
									}
									else
										triggeredAlready = false;
								}
							}
						case 'Blammed':
							{
								if (curBeat > 30 && curBeat < 190)
								{
									if (curBeat < 90 || curBeat > 128)
									{
										if (curBeat % 4 == 2)
										{
											if (!triggeredAlready)
											{
												gf.playAnim('cheer');
												triggeredAlready = true;
											}
										}
										else
											triggeredAlready = false;
									}
								}
							}
						case 'Cocoa':
							{
								if (curBeat < 170)
								{
									if (curBeat < 65 || curBeat > 130 && curBeat < 145)
									{
										if (curBeat % 16 == 15)
										{
											if (!triggeredAlready)
											{
												gf.playAnim('cheer');
												triggeredAlready = true;
											}
										}
										else
											triggeredAlready = false;
									}
								}
							}
						case 'Eggnog':
							{
								if (curBeat > 10 && curBeat != 111 && curBeat < 220)
								{
									if (curBeat % 8 == 7)
									{
										if (!triggeredAlready)
										{
											gf.playAnim('cheer');
											triggeredAlready = true;
										}
									}
									else
										triggeredAlready = false;
								}
							}
					}
				}
			}

			if (!PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
				camearaFollow('dad');
			else
				camearaFollow('bf');
		}

		if (curSong == 'Fresh')
		{
			switch (curBeat)
			{
				case 16:
					gfSpeed = 2;
				case 48:
					gfSpeed = 1;
				case 80:
					gfSpeed = 2;
				case 112:
					gfSpeed = 1;
			}
		}

		if (curSong == 'Bopeebo')
		{
			switch (curBeat)
			{
				case 128, 129, 130:
					if (SONG.needsVoices)
						vocals.volume = 0;
			}
		}

		if (health <= 0 || (FlxG.save.data.resetButton && FlxG.keys.justPressed.R))
		{
			boyfriend.stunned = true;

			persistentUpdate = false;
			persistentDraw = false;
			paused = true;

			if (SONG.needsVoices)
				vocals.stop();

			FlxG.sound.music.stop();

			openSubState(new GameOverSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

			#if desktop
			// Game Over doesn't get his own variable because it's only used here
			DiscordClient.changePresence("GAME OVER -- "
				+ SONG.song
				+ " ("
				+ storyDifficultyText
				+ ") "
				+ Ratings.GenerateLetterRank(accuracy),
				"\nAcc: "
				+ CoolUtil.truncateFloat(accuracy, 2)
				+ "% | Score: "
				+ score
				+ " | Misses: "
				+ misses, iconRPC);
			#end
		}

		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 3500)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				noteCalls(daNote);
			});
		}

		if (!inCutscene)
			keyShit();
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
				//if (daNote.animation.curAnim.name.endsWith('end') && daNote.prevNote != null)
					//daNote.y += daNote.prevNote.height;
				//else
					//daNote.y += daNote.height / 2;

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
				if (camPosDad[0] == 0)
					camFollow.x = dad.getMidpoint().x + 150;
				else
					camFollow.x = dad.getMidpoint().x + camPosDad[0];

				if (camPosDad[1] == 0)
					camFollow.y = dad.getMidpoint().y - 100;
				else
					camFollow.y = dad.getMidpoint().y + camPosDad[1];

				switch (dad.curCharacter)
				{
					case 'mom':
						camFollow.y = dad.getMidpoint().y;
					case 'senpai':
						camFollow.y = dad.getMidpoint().y - 430;
						camFollow.x = dad.getMidpoint().x - 100;
					case 'senpai-angry':
						camFollow.y = dad.getMidpoint().y - 430;
						camFollow.x = dad.getMidpoint().x - 100;
				}

				if (curSong == 'Tutorial')
					tweenCamIn();

			default:
				if (camPosBoyfriend[0] == 0)
					camFollow.x = boyfriend.getMidpoint().x - 100;
				else
					camFollow.x = boyfriend.getMidpoint().x + camPosBoyfriend[0];

				if (camPosBoyfriend[1] == 0)
					camFollow.y = boyfriend.getMidpoint().y - 100;
				else
					camFollow.y = boyfriend.getMidpoint().y + camPosBoyfriend[1];
		}
	}

	private function endSong():Void
	{
		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;

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
					HighScore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
			}
			else
			{
				var difficulty:String = "";

				if (storyDifficulty == 0)
					difficulty = '-easy';

				if (storyDifficulty == 2)
					difficulty = '-hard';

				if (SONG.song.toLowerCase() == 'eggnog')
				{
					var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
						-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
					blackShit.scrollFactor.set();
					add(blackShit);
					camHUD.visible = false;

					FlxG.sound.play(Paths.sound('Lights_Shut_off'));
				}

				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				prevCamFollow = camFollow;

				PlayState.SONG = Song.loadJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
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

	private function popUpScore(daNote:Note):Void
	{
		var noteDiff:Float = Math.abs(Conductor.songPosition - daNote.strumTime);

		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;
		coolText.y -= 350;
		coolText.cameras = [camHUD];

		var rating:FlxSprite = new FlxSprite();
		var ratingScore:Float = 350;

		var daRating = daNote.rating;

		switch (daRating)
		{
			case 'shit':
				ratingScore = -300;
				combo = 0;
				misses++;
				health -= 0.2;
				shits++;
				totalNotesHit += 0.25;
			case 'bad':
				daRating = 'bad';
				ratingScore = 0;
				health -= 0.06;
				bads++;
				totalNotesHit += 0.50;
			case 'good':
				daRating = 'good';
				ratingScore = 200;
				goods++;
				if (health < 2)
					health += 0.04;
				totalNotesHit += 0.75;
			case 'sick':
				if (health < 2)
					health += 0.1;
				totalNotesHit += 1;
				sicks++;
		}

		if (daRating != 'shit' || daRating != 'bad')
		{
			score += Math.round(ratingScore);

			var pixelShitPart1:String = "";
			var pixelShitPart2:String = '';

			if (SONG.stage.startsWith('school'))
			{
				pixelShitPart1 = 'stages/weeb/pixelUI/';
				pixelShitPart2 = '-pixel';
			}

			rating.loadGraphic(Paths.image(pixelShitPart1 + daRating + pixelShitPart2));
			rating.screenCenter();
			rating.y -= 50;
			rating.x = coolText.x - 125;

			if (FlxG.save.data.changedHit)
			{
				rating.x = FlxG.save.data.changedHitX;
				rating.y = FlxG.save.data.changedHitY;
			}
			rating.acceleration.y = 550;
			rating.velocity.y -= FlxG.random.int(140, 175);
			rating.velocity.x -= FlxG.random.int(0, 10);

			var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
			comboSpr.screenCenter();
			comboSpr.x = rating.x;
			comboSpr.y = rating.y + 100;
			comboSpr.acceleration.y = 600;
			comboSpr.velocity.y -= 150;

			comboSpr.velocity.x += FlxG.random.int(1, 10);
			if (!FlxG.save.data.botplay)
			{
				add(rating);
				add(comboSpr);
			}

			if (!SONG.stage.startsWith('school'))
			{
				rating.setGraphicSize(Std.int(rating.width * 0.7));
				rating.antialiasing = true;
				comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
				comboSpr.antialiasing = true;
			}
			else
			{
				rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
				comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.7));
			}

			comboSpr.updateHitbox();
			rating.updateHitbox();

			comboSpr.cameras = [camHUD];
			rating.cameras = [camHUD];

			var seperatedScore:Array<Int> = [];

			var comboSplit:Array<String> = (combo + "").split('');

			if (comboSplit.length == 2)
				seperatedScore.push(0);

			for (i in 0...comboSplit.length)
			{
				var str:String = comboSplit[i];
				seperatedScore.push(Std.parseInt(str));
			}

			var daLoop:Int = 0;
			for (i in seperatedScore)
			{
				var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
				numScore.screenCenter();
				numScore.x = rating.x + (43 * daLoop) - 50;
				numScore.y = rating.y + 100;
				numScore.cameras = [camHUD];

				if (!SONG.stage.startsWith('school'))
				{
					numScore.antialiasing = true;
					numScore.setGraphicSize(Std.int(numScore.width * 0.5));
				}
				else
				{
					numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
				}
				numScore.updateHitbox();

				numScore.acceleration.y = FlxG.random.int(200, 300);
				numScore.velocity.y -= FlxG.random.int(140, 160);
				numScore.velocity.x = FlxG.random.float(-5, 5);

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

			coolText.text = Std.string(seperatedScore);

			FlxTween.tween(rating, {alpha: 0}, 0.2, {startDelay: Conductor.crochet * 0.001});
			FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					coolText.destroy();
					comboSpr.destroy();
					rating.destroy();
				},
				startDelay: Conductor.crochet * 0.001
			});

			curSection += 1;
		}
	}

	public function NearlyEquals(value1:Float, value2:Float, unimportantDifference:Float = 10):Bool
	{
		return Math.abs(FlxMath.roundDecimal(value1, 1) - FlxMath.roundDecimal(value2, 1)) < unimportantDifference;
	}

	private function keyShit():Void
	{
		var controlArray:Array<Bool> = [controls.NOTE_LEFT_P, controls.NOTE_DOWN_P, controls.NOTE_UP_P, controls.NOTE_RIGHT_P];
		var controlHoldArray:Array<Bool> = [controls.NOTE_LEFT, controls.NOTE_DOWN, controls.NOTE_UP, controls.NOTE_RIGHT];
		var controlReleaseArray:Array<Bool> = [controls.NOTE_LEFT_R, controls.NOTE_DOWN_R, controls.NOTE_UP_R, controls.NOTE_RIGHT_R];

		if (!boyfriend.stunned && generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.sustainNote && controlHoldArray[daNote.noteData] && daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit)
					goodNoteHit(daNote);
			});

			if ((controlHoldArray.contains(true) || controlArray.contains(true)) && !endingSong)
			{
				var canMiss:Bool = !FlxG.save.data.ghost;
				if (controlArray.contains(true))
				{
					for (i in 0...controlArray.length)
					{
						var pressNotes:Array<Note> = [];
						var notesDatas:Array<Int> = [];
						var notesStopped:Bool = false;

						var sortedNotesList:Array<Note> = [];
						notes.forEachAlive(function(daNote:Note)
						{
							if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && daNote.noteData == i)
							{
								sortedNotesList.push(daNote);
								notesDatas.push(daNote.noteData);
								canMiss = true;
							}
						});
						sortedNotesList.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

						if (sortedNotesList.length > 0)
						{
							for (epicNote in sortedNotesList)
							{
								for (doubleNote in pressNotes)
								{
									if (Math.abs(doubleNote.strumTime - epicNote.strumTime) < 10)
									{
										doubleNote.kill();
										notes.remove(doubleNote, true);
										doubleNote.destroy();
									}
									else
										notesStopped = true;
								}

								if (controlArray[epicNote.noteData] && !notesStopped)
								{
									goodNoteHit(epicNote);
									pressNotes.push(epicNote);
								}
							}
						}
						else if (canMiss) 
							noteMiss(controlArray[i], i);
					}
				}
			}
			else if (boyfriend.holdTimer > Conductor.stepCrochet * 0.001 * boyfriend.singDuration
				&& boyfriend.animation.curAnim.name.startsWith('sing')
				&& !boyfriend.animation.curAnim.name.endsWith('miss'))
				boyfriend.dance();
		}

		playerStrums.forEach(function(spr:StrumNote)
		{
			if (controlArray[spr.ID] && spr.animation.curAnim.name != 'confirm')
				spr.playAnim('pressed');

			if (controlReleaseArray[spr.ID])
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
			misses++;
			score -= 10;

			FlxG.sound.play(Paths.sound('missnote' + FlxG.random.int(1, 3)), FlxG.random.float(0.1, 0.2));

			switch (direction % 4)
			{
				case 0:
					boyfriend.playAnim('singLEFTmiss', true);
				case 1:
					boyfriend.playAnim('singDOWNmiss', true);
				case 2:
					boyfriend.playAnim('singUPmiss', true);
				case 3:
					boyfriend.playAnim('singRIGHTmiss', true);
			}

			vocals.volume = 0;

			updateAccuracy();
		}
	}

	private function updateAccuracy()
	{
		totalPlayed += 1;
		accuracy = Math.max(0, totalNotesHit / totalPlayed * 100);
		accuracyDefault = Math.max(0, totalNotesHitDefault / totalPlayed * 100);
	}

	private var mashing:Int = 0;
	private var mashViolations:Int = 0;
	private var etternaModeScore:Int = 0;

	private function goodNoteHit(note:Note, resetMashViolation = true):Void
	{
		if (mashing != 0)
			mashing = 0;

		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition);

		note.rating = Ratings.CalculateRating(noteDiff);

		if (!resetMashViolation && mashViolations >= 1)
			mashViolations--;

		if (mashViolations < 0)
			mashViolations = 0;

		if (!note.wasGoodHit)
		{
			if (!note.sustainNote)
			{
				popUpScore(note);
				combo += 1;
			}
			else
				totalNotesHit += 1;

			switch (Math.abs(note.noteData) % 4)
			{
				case 0:
					boyfriend.playAnim('singLEFT', true);
				case 1:
					boyfriend.playAnim('singDOWN', true);
				case 2:
					boyfriend.playAnim('singUP', true);
				case 3:
					boyfriend.playAnim('singRIGHT', true);
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

			updateAccuracy();
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
		callScripts('stepHit', [curStep]);

		super.stepHit();

		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
			resyncVocals();

		#if desktop
		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText
			+ " "
			+ SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ Ratings.GenerateLetterRank(accuracy),
			"Acc: "
			+ CoolUtil.truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ score
			+ " | Misses: "
			+ misses, iconRPC, true,
			songLength
			- Conductor.songPosition);
		#end
	}

	private var lightningStrikeBeat:Int = 0;
	private var lightningOffset:Int = 8;

	override function beatHit()
	{
		callScripts('beatHit', [curBeat]);

		super.beatHit();

		if (generatedMusic)
			notes.sort(FlxSort.byY, (PreferencesData.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING));

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);

			// Dad doesnt interupt his own notes
			if (SONG.notes[Math.floor(curStep / 16)].mustHitSection && dad.curCharacter != 'gf')
				dad.dance();
		}

		if (curBeat % gfSpeed == 0)
			gf.dance();

		if (!boyfriend.animation.curAnim.name.startsWith("sing"))
			boyfriend.dance();

		if (curBeat % 8 == 7 && curSong == 'Bopeebo')
			boyfriend.playAnim('hey', true);

		if (curBeat % 16 == 15 && SONG.song == 'Tutorial' && dad.curCharacter == 'gf' && curBeat > 16 && curBeat < 48)
		{
			boyfriend.playAnim('hey', true);
			dad.playAnim('cheer', true);
		}

		switch (SONG.stage)
		{
			case 'school':
				if (FlxG.save.data.distractions)
					bgGirls.dance();
		}
	}

	override function destroy()
	{
		scriptArray = [];
		super.destroy();
	}

	private function callScripts(funcName:String, ?args:Array<Any>)
		for (i in 0...scriptArray.length)
			scriptArray[i].executeFunc(funcName, args);

	private function setScripts(name:String, val:Dynamic)
		for (i in 0...scriptArray.length)
			scriptArray[i].setVariable(name, val);
}
