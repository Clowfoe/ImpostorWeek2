package;


import flixel.math.FlxRandom;
import Song.Event;
import openfl.media.Sound;
#if sys
import sys.io.File;
import smTools.SMFile;
#end
import openfl.ui.KeyLocation;
import openfl.events.Event;
import haxe.EnumTools;
import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;
import Replay.Ana;
import Replay.Analysis;
#if cpp
import webm.WebmPlayer;
#end
import flixel.input.keyboard.FlxKey;
import haxe.Exception;
import openfl.geom.Matrix;
import openfl.display.BitmapData;
import openfl.utils.AssetType;
import lime.graphics.Image;
import flixel.graphics.FlxGraphic;
import openfl.utils.AssetManifest;
import openfl.utils.AssetLibrary;
import flixel.system.FlxAssets;
import lime.app.Application;
import lime.media.AudioContext;
import lime.media.AudioManager;
import openfl.Lib;
import Section.SwagSection;
import Song.SwagSong;
import WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import flixel.addons.display.FlxBackdrop;
import openfl.filters.ShaderFilter;
#if windows
import Discord.DiscordClient;
#end
#if windows
import Sys;
import sys.FileSystem;
#end

using StringTools;

class PlayState extends MusicBeatState
{
	public static var instance:PlayState = null;

	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var weekSong:Int = 0;
	public static var weekScore:Int = 0;
	public static var shits:Int = 0;
	public static var bads:Int = 0;
	public static var goods:Int = 0;
	public static var sicks:Int = 0;

	public static var songPosBG:FlxSprite;
	public static var songPosBar:FlxBar;

	public static var rep:Replay;
	public static var loadRep:Bool = false;
	public static var inResults:Bool = false;

	public static var noteBools:Array<Bool> = [false, false, false, false];

	var halloweenLevel:Bool = false;

	var songLength:Float = 0;
	var kadeEngineWatermark:FlxText;

	#if windows
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	private var vocals:FlxSound;

	public static var isSM:Bool = false;
	#if sys
	public static var sm:SMFile;
	public static var pathToSm:String;
	#end

	public var originalX:Float;

	public static var dad:Character;
	public static var gf:Character;
	public static var boyfriend:Boyfriend;

	public var notes:FlxTypedGroup<Note>;

	private var unspawnNotes:Array<Note> = [];

	public var strumLine:FlxSprite;

	private var curSection:Int = 0;

	private var camFollow:FlxObject;
	private var lockedCam:Bool = false;

	private static var prevCamFollow:FlxObject;

	public static var strumLineNotes:FlxTypedGroup<FlxSprite> = null;
	public static var playerStrums:FlxTypedGroup<FlxSprite> = null;
	public static var cpuStrums:FlxTypedGroup<FlxSprite> = null;

	private var camZooming:Bool = false;
	private var ejectedBoom:FlxSprite = new FlxSprite();
	private var curSong:String = "";

	private var gfSpeed:Int = 1;

	public var health:Float = 1; // making public because sethealth doesnt work without it

	private var combo:Int = 0;

	public static var misses:Int = 0;
	public static var campaignMisses:Int = 0;
	

	public var accuracy:Float = 0.00;

	private var accuracyDefault:Float = 0.00;
	private var totalNotesHit:Float = 0;
	private var totalNotesHitDefault:Float = 0;
	private var totalPlayed:Int = 0;
	private var ss:Bool = false;

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;
	private var songPositionBar:Float = 0;

	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	public var iconP1:HealthIcon; // making these public again because i may be stupid
	public var iconP2:HealthIcon; // what could go wrong?
	public var camHUD:FlxCamera;
	public var camSustains:FlxCamera;
	public var camNotes:FlxCamera;

	public static var naughtyToday:Bool = true;

	private var camGame:FlxCamera;
	public var cannotDie = false;

	public static var offsetTesting:Bool = false;

	public var isSMFile:Bool = false;

	var deadBF:FlxSprite;

	var notesHitArray:Array<Date> = [];
	var currentFrames:Int = 0;
	var idleToBeat:Bool = true; // change if bf and dad would idle to the beat of the song
	var idleBeat:Int = 4; // how frequently bf and dad would play their idle animation(1 - every beat, 2 - every 2 beats and so on)

	public var dialogue:Array<String> = ['dad:blah blah blah', 'bf:coolswag'];

	var halloweenBG:FlxSprite;
	var isHalloween:Bool = false;

	var fuckingREACTOROFFSET:Float = 0;

	var phillyCityLights:FlxTypedGroup<FlxSprite>;
	var phillyTrain:FlxSprite;
	var bgd:FlxSprite;
	var trainSound:FlxSound;

	var limo:FlxSprite;
	var ass2:FlxSprite;
	var stageFront2:FlxSprite;
	var stageFront3:FlxSprite;
	var stageFront2Dark:FlxSprite;
	var stageFront3Dark:FlxSprite;
	var bgDark:FlxSprite;
	var machineDark:FlxSprite;
	var miraGradient:FlxSprite;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:FlxSprite;
	var songName:FlxText;
	var upperBoppers:FlxSprite;
	var bottomBoppers:FlxSprite;
	var santa:FlxSprite;

	var amogus:FlxSprite;
	var dripster:FlxSprite;
	var yellow:FlxSprite;
	var brown:FlxSprite;

	var bfStartpos:FlxPoint;
	var dadStartpos:FlxPoint;
	var gfStartpos:FlxPoint;

	var cloudScroll:FlxTypedGroup<FlxSprite>;
	var farClouds:FlxTypedGroup<FlxSprite>;

	var orb:FlxSprite = new FlxSprite();

	var crowd:FlxSprite = new FlxSprite();

	var fc:Bool = true;

	var bgGirls:BackgroundGirls;
	var wiggleShit:WiggleEffect = new WiggleEffect();

	var talking:Bool = true;

	public var songScore:Int = 0;

	var songScoreDef:Int = 0;
	var scoreTxt:FlxText;
	var replayTxt:FlxText;

	var speedLines:FlxBackdrop;

	public static var campaignScore:Int = 0;

	var defaultCamZoom:Float = 1.05;

	public static var daPixelZoom:Float = 6;

	public static var theFunne:Bool = true;

	var funneEffect:FlxSprite;
	var inCutscene:Bool = false;
	var usedTimeTravel:Bool = false;

	public static var repPresses:Int = 0;
	public static var repReleases:Int = 0;

	public static var timeCurrently:Float = 0;
	public static var timeCurrentlyR:Float = 0;

	// Will fire once to prevent debug spam messages and broken animations
	private var triggeredAlready:Bool = false;

	// Will decide if she's even allowed to headbang at all depending on the song
	private var allowedToHeadbang:Bool = false;

	// Per song additive offset
	public static var songOffset:Float = 0;

	var speedPass:Array<Float> = [11000, 11000, 11000, 11000];
	var farSpeedPass:Array<Float> = [11000, 11000, 11000, 11000, 11000, 11000, 11000];

	//array of two objects get ufkced
	var middleBuildings:Array<FlxSprite>;
	var rightBuildings:Array<FlxSprite>;
	var leftBuildings:Array<FlxSprite>;
	var fgCloud:FlxSprite;

	// BotPlay text
	private var botPlayState:FlxText;
	// Replay shit
	private var saveNotes:Array<Dynamic> = [];
	private var saveJudge:Array<String> = [];
	private var replayAna:Analysis = new Analysis(); // replay analysis

	public static var highestCombo:Int = 0;

	private var executeModchart = false;

	// Animation common suffixes
	private var dataSuffix:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
	private var dataColor:Array<String> = ['purple', 'blue', 'green', 'red'];

	public static var startTime = 0.0;

	// API stuff

	public function addObject(object:FlxBasic)
	{
		add(object);
	}

	public function removeObject(object:FlxBasic)
	{
		remove(object);
	}

	// sussy variable
	var _cb = 0;

	var flashSprite:FlxSprite = new FlxSprite(0, 0).makeGraphic(1280, 720, 0xFFb30000);
	var lightsOutSprite:FlxSprite = new FlxSprite(-700, -70).makeGraphic(10000, 10000, 0xFF000000);
	
	override public function create()
	{

		FlxG.mouse.visible = false;
		instance = this;

		if (FlxG.save.data.fpsCap > 290)
			(cast(Lib.current.getChildAt(0), Main)).setFPSCap(800);

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		if (!isStoryMode)
		{
			sicks = 0;
			bads = 0;
			shits = 0;
			goods = 0;
		}
		misses = 0;

		highestCombo = 0;
		repPresses = 0;
		repReleases = 0;
		inResults = false;

		PlayStateChangeables.useDownscroll = FlxG.save.data.downscroll;
		PlayStateChangeables.safeFrames = FlxG.save.data.frames;
		PlayStateChangeables.scrollSpeed = FlxG.save.data.scrollSpeed;
		PlayStateChangeables.botPlay = FlxG.save.data.botplay;
		PlayStateChangeables.Optimize = FlxG.save.data.optimize;

		// pre lowercasing the song name (create)
		var songLowercase = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase();
		switch (songLowercase)
		{
			case 'dad-battle':
				songLowercase = 'dadbattle';
			case 'philly-nice':
				songLowercase = 'philly';
		}

		removedVideo = false;

		#if windows
		executeModchart = FileSystem.exists(Paths.lua(songLowercase + "/modchart"));
		if (isSM)
			executeModchart = FileSystem.exists(pathToSm + "/modchart.lua");
		if (executeModchart)
			PlayStateChangeables.Optimize = false;
		#end
		#if !cpp
		executeModchart = false; // FORCE disable for non cpp targets
		#end

		trace('Mod chart: ' + executeModchart + " - " + Paths.lua(songLowercase + "/modchart"));

		#if windows
		// Making difficulty text for Discord Rich Presence.
		storyDifficultyText = CoolUtil.difficultyFromInt(storyDifficulty);

		iconRPC = SONG.player2;

		// To avoid having duplicate images in Discord assets
		switch (iconRPC)
		{
			case 'senpai-angry':
				iconRPC = 'senpai';
			case 'monster-christmas':
				iconRPC = 'monster';
			case 'mom-car':
				iconRPC = 'mom';
		}

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			detailsText = "Story Mode: Week " + (storyWeek + 1);
		}
		else
		{
			detailsText = "Freeplay";
		}

		// String for when the game is paused
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
			+ HelperFunctions.truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC);
		#end

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camSustains = new FlxCamera();
		camSustains.bgColor.alpha = 0;
		camNotes = new FlxCamera();
		camNotes.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camSustains);
		FlxG.cameras.add(camNotes);

		FlxCamera.defaultCameras = [camGame];

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial', 'tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		if (SONG.eventObjects == null)
			{
				SONG.eventObjects = [new Song.Event("Init BPM",0,SONG.bpm,"BPM Change")];
			}
	

		TimingStruct.clearTimings();

		var convertedStuff:Array<Song.Event> = [];

		var currentIndex = 0;
		for (i in SONG.eventObjects)
		{
			var name = Reflect.field(i,"name");
			var type = Reflect.field(i,"type");
			var pos = Reflect.field(i,"position");
			var value = Reflect.field(i,"value");

			if (type == "BPM Change")
			{
                var beat:Float = pos;

                var endBeat:Float = Math.POSITIVE_INFINITY;

                TimingStruct.addTiming(beat,value,endBeat, 0); // offset in this case = start time since we don't have a offset
				
                if (currentIndex != 0)
                {
                    var data = TimingStruct.AllTimings[currentIndex - 1];
                    data.endBeat = beat;
                    data.length = (data.endBeat - data.startBeat) / (data.bpm / 60);
					TimingStruct.AllTimings[currentIndex].startTime = data.startTime + data.length;
                }

				currentIndex++;
			}
			convertedStuff.push(new Song.Event(name,pos,value,type));
		}

		SONG.eventObjects = convertedStuff;

		trace('INFORMATION ABOUT WHAT U PLAYIN WIT:\nFRAMES: ' + PlayStateChangeables.safeFrames + '\nZONE: ' + Conductor.safeZoneOffset + '\nTS: '
			+ Conductor.timeScale + '\nBotPlay : ' + PlayStateChangeables.botPlay);

		var nnSuffix:String = "";
		if(!naughtyToday)
			nnSuffix = '-nn';
		// dialogue shit
		switch (songLowercase)
		{
			case 'tutorial':
				dialogue = ["Hey you're pretty cute.", 'Use the arrow keys to keep up \nwith me singing.'];
			case 'bopeebo':
				dialogue = [
					'HEY!',
					"You think you can just sing\nwith my daughter like that?",
					"If you want to date her...",
					"You're going to have to go \nthrough ME first!"
				];
			case 'fresh':
				dialogue = ["Not too shabby boy.", ""];
			case 'dadbattle':
				dialogue = [
					"gah you think you're hot stuff?",
					"If you can beat me here...",
					"Only then I will even CONSIDER letting you\ndate my daughter!"
				];
			case 'senpai':
				dialogue = CoolUtil.coolTextFile(Paths.txt('data/senpai/senpaiDialogue'));
			case 'sussus-moogus':
				dialogue = CoolUtil.coolTextFile(Paths.txt('data/sussus-moogus/moogus' + nnSuffix));
			case 'sabotage':
				dialogue = CoolUtil.coolTextFile(Paths.txt('data/sabotage/sabotage' + nnSuffix));
			case 'meltdown':
				dialogue = CoolUtil.coolTextFile(Paths.txt('data/meltdown/meltdown' + nnSuffix));
			case 'sussus-toogus':
				dialogue = CoolUtil.coolTextFile(Paths.txt('data/sussus-toogus/toogus' + nnSuffix));
			case 'lights-down':
				dialogue = CoolUtil.coolTextFile(Paths.txt('data/lights-down/down' + nnSuffix));
			case 'reactor':
				dialogue = CoolUtil.coolTextFile(Paths.txt('data/reactor/reactor'));
			case 'roses':
				dialogue = CoolUtil.coolTextFile(Paths.txt('data/roses/rosesDialogue'));
			case 'thorns':
				dialogue = CoolUtil.coolTextFile(Paths.txt('data/thorns/thornsDialogue'));
		}

		// defaults if no stage was found in chart
		var stageCheck:String = 'stage';

		if (SONG.stage == null)
		{
			switch (storyWeek)
			{
				case 2:
					stageCheck = 'halloween';
				case 3:
					stageCheck = 'philly';
				case 4:
					stageCheck = 'limo';
				case 5:
					if (songLowercase == 'winter-horrorland')
					{
						stageCheck = 'mallEvil';
					}
					else
					{
						stageCheck = 'mall';
					}
				case 6:
					if (songLowercase == 'thorns')
					{
						stageCheck = 'schoolEvil';
					}
					else
					{
						stageCheck = 'school';
					}
					// i should check if its stage (but this is when none is found in chart anyway)
			}
		}
		else
		{
			stageCheck = SONG.stage;
		}

		if (!PlayStateChangeables.Optimize)
		{
			switch (stageCheck)
			{
				case 'halloween':
					{
						curStage = 'spooky';
						halloweenLevel = true;

						var hallowTex = Paths.getSparrowAtlas('halloween_bg', 'week2');

						halloweenBG = new FlxSprite(-200, -100);
						halloweenBG.frames = hallowTex;
						halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
						halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
						halloweenBG.animation.play('idle');
						if(FlxG.save.data.antialiasing)
							{
								halloweenBG.antialiasing = true;
							}
						add(halloweenBG);

						isHalloween = true;
					}
				case 'philly':
					{
						curStage = 'philly';

						var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('philly/sky', 'week3'));
						bg.scrollFactor.set(0.1, 0.1);
						add(bg);

						var city:FlxSprite = new FlxSprite(-10).loadGraphic(Paths.image('philly/city', 'week3'));
						city.scrollFactor.set(0.3, 0.3);
						city.setGraphicSize(Std.int(city.width * 0.85));
						city.updateHitbox();
						add(city);

						phillyCityLights = new FlxTypedGroup<FlxSprite>();
						if (FlxG.save.data.distractions)
						{
							add(phillyCityLights);
						}

						for (i in 0...5)
						{
							var light:FlxSprite = new FlxSprite(city.x).loadGraphic(Paths.image('philly/win' + i, 'week3'));
							light.scrollFactor.set(0.3, 0.3);
							light.visible = false;
							light.setGraphicSize(Std.int(light.width * 0.85));
							light.updateHitbox();
							if(FlxG.save.data.antialiasing)
								{
									light.antialiasing = true;
								}
							phillyCityLights.add(light);
						}

						var streetBehind:FlxSprite = new FlxSprite(-40, 50).loadGraphic(Paths.image('philly/behindTrain', 'week3'));
						add(streetBehind);

						phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.image('philly/train', 'week3'));
						if (FlxG.save.data.distractions)
						{
							add(phillyTrain);
						}

						trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes', 'week3'));
						FlxG.sound.list.add(trainSound);

						// var cityLights:FlxSprite = new FlxSprite().loadGraphic(AssetPaths.win0.png);

						var street:FlxSprite = new FlxSprite(-40, streetBehind.y).loadGraphic(Paths.image('philly/street', 'week3'));
						add(street);
					}
				case 'limo':
					{
						curStage = 'limo';
						defaultCamZoom = 0.90;

						var skyBG:FlxSprite = new FlxSprite(-120, -50).loadGraphic(Paths.image('limo/limoSunset', 'week4'));
						skyBG.scrollFactor.set(0.1, 0.1);
						add(skyBG);

						var bgLimo:FlxSprite = new FlxSprite(-200, 480);
						bgLimo.frames = Paths.getSparrowAtlas('limo/bgLimo', 'week4');
						bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
						bgLimo.animation.play('drive');
						bgLimo.scrollFactor.set(0.4, 0.4);
						add(bgLimo);
						if (FlxG.save.data.distractions)
						{
							grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
							add(grpLimoDancers);

							for (i in 0...5)
							{
								var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
								dancer.scrollFactor.set(0.4, 0.4);
								grpLimoDancers.add(dancer);
							}
						}

						var overlayShit:FlxSprite = new FlxSprite(-500, -600).loadGraphic(Paths.image('limo/limoOverlay', 'week4'));
						overlayShit.alpha = 0.5;
						// add(overlayShit);

						// var shaderBullshit = new BlendModeEffect(new OverlayShader(), FlxColor.RED);

						// FlxG.camera.setFilters([new ShaderFilter(cast shaderBullshit.shader)]);

						// overlayShit.shader = shaderBullshit;

						var limoTex = Paths.getSparrowAtlas('limo/limoDrive', 'week4');

						limo = new FlxSprite(-120, 550);
						limo.frames = limoTex;
						limo.animation.addByPrefix('drive', "Limo stage", 24);
						limo.animation.play('drive');
						if(FlxG.save.data.antialiasing)
							{
								limo.antialiasing = true;
							}

						fastCar = new FlxSprite(-300, 160).loadGraphic(Paths.image('limo/fastCarLol', 'week4'));
						// add(limo);
					}
				case 'mall':
					{
						curStage = 'mall';

						defaultCamZoom = 0.80;

						var bg:FlxSprite = new FlxSprite(-1000, -500).loadGraphic(Paths.image('christmas/bgWalls', 'week5'));
						if(FlxG.save.data.antialiasing)
							{
								bg.antialiasing = true;
							}
						bg.scrollFactor.set(0.2, 0.2);
						bg.active = false;
						bg.setGraphicSize(Std.int(bg.width * 0.8));
						bg.updateHitbox();
						add(bg);

						upperBoppers = new FlxSprite(-240, -90);
						upperBoppers.frames = Paths.getSparrowAtlas('christmas/upperBop', 'week5');
						upperBoppers.animation.addByPrefix('bop', "Upper Crowd Bob", 24, false);
						if(FlxG.save.data.antialiasing)
							{
								upperBoppers.antialiasing = true;
							}
						upperBoppers.scrollFactor.set(0.33, 0.33);
						upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
						upperBoppers.updateHitbox();
						if (FlxG.save.data.distractions)
						{
							add(upperBoppers);
						}

						var bgEscalator:FlxSprite = new FlxSprite(-1100, -600).loadGraphic(Paths.image('christmas/bgEscalator', 'week5'));
						if(FlxG.save.data.antialiasing)
							{
								bgEscalator.antialiasing = true;
							}
						bgEscalator.scrollFactor.set(0.3, 0.3);
						bgEscalator.active = false;
						bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
						bgEscalator.updateHitbox();
						add(bgEscalator);

						var tree:FlxSprite = new FlxSprite(370, -250).loadGraphic(Paths.image('christmas/christmasTree', 'week5'));
						if(FlxG.save.data.antialiasing)
							{
								tree.antialiasing = true;
							}
						tree.scrollFactor.set(0.40, 0.40);
						add(tree);

						bottomBoppers = new FlxSprite(-300, 140);
						bottomBoppers.frames = Paths.getSparrowAtlas('christmas/bottomBop', 'week5');
						bottomBoppers.animation.addByPrefix('bop', 'Bottom Level Boppers', 24, false);
						if(FlxG.save.data.antialiasing)
							{
								bottomBoppers.antialiasing = true;
							}
						bottomBoppers.scrollFactor.set(0.9, 0.9);
						bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
						bottomBoppers.updateHitbox();
						if (FlxG.save.data.distractions)
						{
							add(bottomBoppers);
						}

						var fgSnow:FlxSprite = new FlxSprite(-600, 700).loadGraphic(Paths.image('christmas/fgSnow', 'week5'));
						fgSnow.active = false;
						if(FlxG.save.data.antialiasing)
							{
								fgSnow.antialiasing = true;
							}
						add(fgSnow);

						santa = new FlxSprite(-840, 150);
						santa.frames = Paths.getSparrowAtlas('christmas/santa', 'week5');
						santa.animation.addByPrefix('idle', 'santa idle in fear', 24, false);
						if(FlxG.save.data.antialiasing)
							{
								santa.antialiasing = true;
							}
						if (FlxG.save.data.distractions)
						{
							add(santa);
						}
					}
				case 'mallEvil':
					{
						curStage = 'mallEvil';
						var bg:FlxSprite = new FlxSprite(-400, -500).loadGraphic(Paths.image('christmas/evilBG', 'week5'));
						if(FlxG.save.data.antialiasing)
							{
								bg.antialiasing = true;
							}
						bg.scrollFactor.set(0.2, 0.2);
						bg.active = false;
						bg.setGraphicSize(Std.int(bg.width * 0.8));
						bg.updateHitbox();
						add(bg);

						var evilTree:FlxSprite = new FlxSprite(300, -300).loadGraphic(Paths.image('christmas/evilTree', 'week5'));
						if(FlxG.save.data.antialiasing)
							{
								evilTree.antialiasing = true;
							}
						evilTree.scrollFactor.set(0.2, 0.2);
						add(evilTree);

						var evilSnow:FlxSprite = new FlxSprite(-200, 700).loadGraphic(Paths.image("christmas/evilSnow", 'week5'));
						if(FlxG.save.data.antialiasing)
							{
								evilSnow.antialiasing = true;
							}
						add(evilSnow);
					}
				case 'school':
					{
						curStage = 'school';

						// defaultCamZoom = 0.9;

						var bgSky = new FlxSprite().loadGraphic(Paths.image('weeb/weebSky'));
						bgSky.scrollFactor.set(0, 0);
						add(bgSky);

						var repositionShit = -200;

						var bgSchool:FlxSprite = new FlxSprite(repositionShit, 0).loadGraphic(Paths.image('weeb/weebSchool'));
						bgSchool.scrollFactor.set(0.6, 0.90);
						add(bgSchool);

						var bgStreet:FlxSprite = new FlxSprite(repositionShit).loadGraphic(Paths.image('weeb/weebStreet'));
						bgStreet.scrollFactor.set(0.95, 0.95);
						add(bgStreet);

						var fgTrees:FlxSprite = new FlxSprite(repositionShit + 170, 130).loadGraphic(Paths.image('weeb/weebTreesBack'));
						fgTrees.scrollFactor.set(0.9, 0.9);
						add(fgTrees);

						var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
						var treetex = Paths.getPackerAtlas('weeb/weebTrees');
						bgTrees.frames = treetex;
						bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
						bgTrees.animation.play('treeLoop');
						bgTrees.scrollFactor.set(0.85, 0.85);
						add(bgTrees);

						var treeLeaves:FlxSprite = new FlxSprite(repositionShit, -40);
						treeLeaves.frames = Paths.getSparrowAtlas('weeb/petals');
						treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
						treeLeaves.animation.play('leaves');
						treeLeaves.scrollFactor.set(0.85, 0.85);
				//		add(treeLeaves);

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

						if (songLowercase == 'roses')
						{
							if (FlxG.save.data.distractions)
							{
								bgGirls.getScared();
							}
						}

						bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
						bgGirls.updateHitbox();
						if (FlxG.save.data.distractions)
						{
							add(bgGirls);
						}
					}
				case 'schoolEvil':
					{
						curStage = 'schoolEvil';

						if (!PlayStateChangeables.Optimize)
						{
							var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
							var waveEffectFG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 5, 2);
						}

						var posX = 400;
						var posY = 200;

						var bg:FlxSprite = new FlxSprite(posX, posY);
						bg.frames = Paths.getSparrowAtlas('weeb/animatedEvilSchool', 'week6');
						bg.animation.addByPrefix('idle', 'background 2', 24);
						bg.animation.play('idle');
						bg.scrollFactor.set(0.8, 0.9);
						bg.scale.set(6, 6);
						add(bg);

						/* 
							var bg:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.image('weeb/evilSchoolBG'));
							bg.scale.set(6, 6);
							// bg.setGraphicSize(Std.int(bg.width * 6));
							// bg.updateHitbox();
							add(bg);
							var fg:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.image('weeb/evilSchoolFG'));
							fg.scale.set(6, 6);
							// fg.setGraphicSize(Std.int(fg.width * 6));
							// fg.updateHitbox();
							add(fg);
							wiggleShit.effectType = WiggleEffectType.DREAMY;
							wiggleShit.waveAmplitude = 0.01;
							wiggleShit.waveFrequency = 60;
							wiggleShit.waveSpeed = 0.8;
						 */

						// bg.shader = wiggleShit.shader;
						// fg.shader = wiggleShit.shader;

						/* 
							var waveSprite = new FlxEffectSprite(bg, [waveEffectBG]);
							var waveSpriteFG = new FlxEffectSprite(fg, [waveEffectFG]);
							// Using scale since setGraphicSize() doesnt work???
							waveSprite.scale.set(6, 6);
							waveSpriteFG.scale.set(6, 6);
							waveSprite.setPosition(posX, posY);
							waveSpriteFG.setPosition(posX, posY);
							waveSprite.scrollFactor.set(0.7, 0.8);
							waveSpriteFG.scrollFactor.set(0.9, 0.8);
							// waveSprite.setGraphicSize(Std.int(waveSprite.width * 6));
							// waveSprite.updateHitbox();
							// waveSpriteFG.setGraphicSize(Std.int(fg.width * 6));
							// waveSpriteFG.updateHitbox();
							add(waveSprite);
							add(waveSpriteFG);
						 */
					}
					case 'toogus':
						{
								defaultCamZoom = 0.85;
								curStage = 'toogus';
								var bg:FlxSprite = new FlxSprite(0,50).loadGraphic(Paths.image('Mira'));
								bg.setGraphicSize(Std.int(bg.width * 1.4));
								bg.antialiasing = true;
								bg.scrollFactor.set(1, 1);
								bg.active = false;
								add(bg);

								bgDark = new FlxSprite(0,50).loadGraphic(Paths.image('MiraDark'));
								bgDark.setGraphicSize(Std.int(bgDark.width * 1.4));
								bgDark.antialiasing = true;
								bgDark.scrollFactor.set(1, 1);
								bgDark.active = false;
								bgDark.alpha = 0;
								add(bgDark);

								var stageFront:FlxSprite = new FlxSprite(1000, 150).loadGraphic(Paths.image('vending_machine'));
								stageFront.updateHitbox();
								stageFront.antialiasing = true;
								stageFront.scrollFactor.set(1, 1);
								stageFront.active = false;
								add(stageFront);

								machineDark = new FlxSprite(1000, 150).loadGraphic(Paths.image('vending_machineDark'));
								machineDark.updateHitbox();
								machineDark.antialiasing = true;
								machineDark.scrollFactor.set(1, 1);
								machineDark.active = false;
								machineDark.alpha = 0;
								add(machineDark);
								
								var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
								stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
								stageCurtains.updateHitbox();
								stageCurtains.antialiasing = true;
								stageCurtains.scrollFactor.set(1.3, 1.3);
								stageCurtains.active = false;

								lightsOutSprite.alpha = 0;
								flashSprite.scrollFactor.set(0, 0);
								add(lightsOutSprite); // lights out stuff
			
							//	add(stageCurtains);
						}
					case 'reactor':
						{
								defaultCamZoom = 0.5;
								curStage = 'reactor';
								var bg:FlxSprite = new FlxSprite(-2300,-1700).loadGraphic(Paths.image('reactor/reactor background', 'impostor'));
								bg.setGraphicSize(Std.int(bg.width * 0.7));
								bg.antialiasing = true;
								bg.scrollFactor.set(1, 1);
								bg.active = false;
								add(bg);

								yellow = new FlxSprite(-400, 150);
								yellow.frames = Paths.getSparrowAtlas('reactor/susBoppers', 'impostor');
								yellow.animation.addByPrefix('bop', 'yellow sus', 24, false);
								yellow.animation.play('bop');
								yellow.setGraphicSize(Std.int(yellow.width * 0.7));
								yellow.antialiasing = true;
								yellow.scrollFactor.set(1, 1);
								yellow.active = true;
								add(yellow);

								var pillar1:FlxSprite = new FlxSprite(-2300,-1700).loadGraphic(Paths.image('reactor/back pillars', 'impostor'));
								pillar1.setGraphicSize(Std.int(pillar1.width * 0.7));
								pillar1.antialiasing = true;
								pillar1.scrollFactor.set(1, 1);
								pillar1.active = false;
								add(pillar1);

								dripster = new FlxSprite(1375, 150);
								dripster.frames = Paths.getSparrowAtlas('reactor/susBoppers', 'impostor');
								dripster.animation.addByPrefix('bop', 'blue sus', 24, false);
								dripster.animation.play('bop');
								dripster.setGraphicSize(Std.int(dripster.width * 0.7));
								dripster.antialiasing = true;
								dripster.scrollFactor.set(1, 1);
								dripster.active = true;
								add(dripster);

								var pillar2:FlxSprite = new FlxSprite(-2300,-1700).loadGraphic(Paths.image('reactor/middle pillars', 'impostor'));
								pillar2.setGraphicSize(Std.int(pillar2.width * 0.7));
								pillar2.antialiasing = true;
								pillar2.scrollFactor.set(1, 1);
								pillar2.active = false;
								add(pillar2);

								amogus = new FlxSprite(1670, 250);
								amogus.frames = Paths.getSparrowAtlas('reactor/susBoppers', 'impostor');
								amogus.animation.addByPrefix('bop', 'white sus', 24, false);
								amogus.animation.play('bop');
								amogus.setGraphicSize(Std.int(amogus.width * 0.7));
								amogus.antialiasing = true;
								amogus.scrollFactor.set(1, 1);
								amogus.active = true;
								add(amogus);

								brown = new FlxSprite(-850, 190);
								brown.frames = Paths.getSparrowAtlas('reactor/susBoppers', 'impostor');
								brown.animation.addByPrefix('bop', 'brown sus', 24, false);
								brown.animation.play('bop');
								brown.setGraphicSize(Std.int(brown.width * 0.7));
								brown.antialiasing = true;
								brown.scrollFactor.set(1, 1);
								brown.active = true;
								add(brown);

								var pillar3:FlxSprite = new FlxSprite(-2300,-1700).loadGraphic(Paths.image('reactor/front pillars', 'impostor'));
								pillar3.setGraphicSize(Std.int(pillar3.width * 0.7));
								pillar3.antialiasing = true;
								pillar3.scrollFactor.set(1, 1);
								pillar3.active = false;
								add(pillar3);

								orb = new FlxSprite(-460,-1300).loadGraphic(Paths.image('reactor/ball of big ol energy', 'impostor'));
								orb.setGraphicSize(Std.int(orb.width * 0.7));
								orb.antialiasing = true;
								orb.scrollFactor.set(1, 1);
								orb.active = false;
								add(orb);

								var cranes:FlxSprite = new FlxSprite(-735, -1500).loadGraphic(Paths.image('reactor/upper cranes', 'impostor'));
								cranes.setGraphicSize(Std.int(cranes.width * 0.7));
								cranes.antialiasing = true;
								cranes.scrollFactor.set(1, 1);
								cranes.active = false;
								add(cranes);

								var console1:FlxSprite = new FlxSprite(-260,150).loadGraphic(Paths.image('reactor/center console', 'impostor'));
								console1.setGraphicSize(Std.int(console1.width * 0.7));
								console1.antialiasing = true;
								console1.scrollFactor.set(1, 1);
								console1.active = false;
								add(console1);

								
								var console2:FlxSprite = new FlxSprite(-1380,450).loadGraphic(Paths.image('reactor/side console', 'impostor'));
								console2.setGraphicSize(Std.int(console2.width * 0.7));
								console2.antialiasing = true;
								console2.scrollFactor.set(1, 1);
								console2.active = false;
								add(console2);						
								

			
							//	add(stageCurtains);
						}
					case 'polus': {
						curStage = 'polus';
						defaultCamZoom = 0.9;  
 
						var sky:FlxSprite = new FlxSprite(-834.3, -620.5).loadGraphic(Paths.image('polus/polusSky', 'impostor'));
						sky.antialiasing = true;
						sky.scrollFactor.set(0.5, 0.5);
						sky.active = false;
						add(sky);		
		
						var rocks:FlxSprite = new FlxSprite(-915.8, -411.3).loadGraphic(Paths.image('polus/polusrocks', 'impostor'));
						rocks.updateHitbox();
						rocks.antialiasing = true;
						rocks.scrollFactor.set(0.6, 0.6);
						rocks.active = false;
						add(rocks);	
						
						var hills:FlxSprite = new FlxSprite(-1238.05, -180.55).loadGraphic(Paths.image('polus/polusHills', 'impostor'));
						hills.updateHitbox();
						hills.antialiasing = true;
						hills.scrollFactor.set(0.9, 0.9);
						hills.active = false;
						add(hills);

						var warehouse:FlxSprite = new FlxSprite(-458.35, -315.6).loadGraphic(Paths.image('polus/polusWarehouse', 'impostor'));
						warehouse.updateHitbox();
						warehouse.antialiasing = true;
						warehouse.scrollFactor.set(0.9, 0.9);
						warehouse.active = false;
						add(warehouse);

						var crowd:FlxSprite = new FlxSprite(-280.5, 240.8);
						crowd.frames = Paths.getSparrowAtlas('polus/CrowdBop', 'impostor');
						crowd.animation.addByPrefix('CrowdBop', 'CrowdBop', 24);
						crowd.animation.play('CrowdBop');
						crowd.scrollFactor.set(1, 1);
						crowd.antialiasing = true;
						crowd.updateHitbox();
						crowd.scale.set(1.5, 1.5);
						if(SONG.song.toLowerCase() == 'meltdown') {
							add(crowd);
						}

						
						var ground:FlxSprite = new FlxSprite(-580.9, 241.85).loadGraphic(Paths.image('polus/polusGround', 'impostor'));
						ground.updateHitbox();
						ground.antialiasing = true;
						ground.scrollFactor.set(1, 1);
						ground.active = false;
						add(ground);

						deadBF = new FlxSprite(532.95, 465.95).loadGraphic(Paths.image('polus/bfdead', 'impostor'));
						deadBF.antialiasing = true;
						deadBF.scrollFactor.set(1, 1);
						deadBF.updateHitbox();						

					}
					case 'ejected':
					{
						defaultCamZoom = 0.45;
						curStage = 'ejected';
						cloudScroll = new FlxTypedGroup<FlxSprite>();
						farClouds = new FlxTypedGroup<FlxSprite>();
						var sky:FlxSprite = new FlxSprite(-2372.25, -4181.7).loadGraphic(Paths.image('ejected/sky', 'impostor'));
						sky.antialiasing = true;
						sky.updateHitbox();
						sky.scrollFactor.set(0, 0);			
						add(sky);

						fgCloud = new FlxSprite(-2660.4, -402).loadGraphic(Paths.image('ejected/fgClouds', 'impostor'));
						fgCloud.antialiasing = true;
						fgCloud.updateHitbox();
						fgCloud.scrollFactor.set(0.2, 0.2);
						add(fgCloud);

						for(i in 0...farClouds.members.length) {
							add(farClouds.members[i]);
						}
						add(farClouds);

						rightBuildings = [];
						leftBuildings = [];
						middleBuildings = [];
						for(i in 0...2) {
							var rightBuilding = new FlxSprite(1022.3, -390.45);
							rightBuilding.frames = Paths.getSparrowAtlas('ejected/buildingSheet', 'impostor');
							rightBuilding.animation.addByPrefix('1', 'BuildingB1', 24, false);
							rightBuilding.animation.addByPrefix('2', 'BuildingB2', 24, false);
							rightBuilding.animation.play('1');
							rightBuilding.antialiasing = true;
							rightBuilding.updateHitbox();
							rightBuilding.scrollFactor.set(0.5, 0.5);
							add(rightBuilding);
							rightBuildings.push(rightBuilding);
						}
						
						for(i in 0...2) {
							var middleBuilding = new FlxSprite(-76.15, 1398.5);
							middleBuilding.frames = Paths.getSparrowAtlas('ejected/buildingSheet', 'impostor');
							middleBuilding.animation.addByPrefix('1', 'BuildingA1', 24, false);
							middleBuilding.animation.addByPrefix('2', 'BuildingA2', 24, false);
							middleBuilding.animation.play('1');
							middleBuilding.antialiasing = true;
							middleBuilding.updateHitbox();
							middleBuilding.scrollFactor.set(0.5, 0.5);
							add(middleBuilding);
							middleBuildings.push(middleBuilding);
						}
						
						for(i in 0...2) {
							var leftBuilding = new FlxSprite(-1099.3, 7286.55);
							leftBuilding.frames = Paths.getSparrowAtlas('ejected/buildingSheet', 'impostor');
							leftBuilding.animation.addByPrefix('1', 'BuildingB1', 24, false);
							leftBuilding.animation.addByPrefix('2', 'BuildingB2', 24, false);
							leftBuilding.animation.play('1');
							leftBuilding.antialiasing = true;
							leftBuilding.updateHitbox();
							leftBuilding.scrollFactor.set(0.5, 0.5);
							add(leftBuilding);
							leftBuildings.push(leftBuilding);
						}

						rightBuildings[0].y = 6803.1;
						middleBuildings[0].y = 8570.5;
						leftBuildings[0].y = 14050.2;

						for(i in 0...3) {
							//now i could add the clouds manually
							//but i wont!!! trolled
							var newCloud:FlxSprite = new FlxSprite();
							newCloud.frames = Paths.getSparrowAtlas('ejected/scrollingClouds', 'impostor');
							newCloud.animation.addByPrefix('idle', 'Cloud' + i, 24, false);
							newCloud.animation.play('idle');
							newCloud.updateHitbox();
							newCloud.alpha = 1;
							
							switch(i) {
								case 0:
									newCloud.setPosition(-9.65, -224.35);
									newCloud.scrollFactor.set(0.8, 0.8);
								case 1:
									newCloud.setPosition(-1342.85, -350.45);
									newCloud.scrollFactor.set(0.6, 0.6);
								case 2:
									newCloud.setPosition(1784.65, -957.05);
									newCloud.scrollFactor.set(1.3, 1.3);
								case 3:
									newCloud.setPosition(-2217.45, -1377.65);
									newCloud.scrollFactor.set(1, 1);
							}
							cloudScroll.add(newCloud);								
						}

						for(i in 0...7) {
							var newCloud:FlxSprite = new FlxSprite();
							newCloud.frames = Paths.getSparrowAtlas('ejected/scrollingClouds', 'impostor');
							newCloud.animation.addByPrefix('idle', 'Cloud' + i, 24, false);
							newCloud.animation.play('idle');
							newCloud.updateHitbox();
							newCloud.alpha = 0.5;
							
							switch(i) {
								case 0:
									newCloud.setPosition(-1308, -1039.9);
								case 1:
									newCloud.setPosition(464.3, -890.5);
								case 2:
									newCloud.setPosition(2458.45, -1085.85);
								case 3:
									newCloud.setPosition(-666.95, -172.05);
								case 4:
									newCloud.setPosition(-1616.6, 1016.95);
								case 5:
									newCloud.setPosition(1714.25, 200.45);
								case 6:
									newCloud.setPosition(-167.05, 710.25);
							}
							farClouds.add(newCloud);								
						}

						speedLines = new FlxBackdrop(Paths.image('ejected/speedLines', 'impostor'), 1, 1, true, true);
						speedLines.antialiasing = true;
						speedLines.updateHitbox();
						speedLines.scrollFactor.set(1.3, 1.3);
						speedLines.alpha = 0.3;
											
					}
					case 'defeat':
					{
						defaultCamZoom = 0.9;
						curStage = 'defeat';
						var defeat:FlxSprite = new FlxSprite(0, 100).loadGraphic(Paths.image('defeatfnf', 'shared'));		
						defeat.setGraphicSize(Std.int(defeat.width * 2));
						defeat.scrollFactor.set(1,1);
						defeat.antialiasing = true;
						add(defeat);
					}
					default:
					{
						defaultCamZoom = 0.9;
						curStage = 'stage';
						var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback'));
						bg.antialiasing = true;
						bg.scrollFactor.set(0.9, 0.9);
						bg.active = false;
						add(bg);
	
						var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
						stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
						stageFront.updateHitbox();
						stageFront.antialiasing = true;
						stageFront.scrollFactor.set(0.9, 0.9);
						stageFront.active = false;
						add(stageFront);
	
						var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
						stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
						stageCurtains.updateHitbox();
						stageCurtains.antialiasing = true;
						stageCurtains.scrollFactor.set(1.3, 1.3);
						stageCurtains.active = false;
	
						add(stageCurtains);		
					}
			}
		}
		// defaults if no gf was found in chart
		var gfCheck:String = 'gf';

		if (SONG.gfVersion == null)
		{
			switch (storyWeek)
			{
				case 4:
					gfCheck = 'gf-car';
				case 5:
					gfCheck = 'gf-christmas';
				case 6:
					gfCheck = 'gf-pixel';
			}
		}
		else
		{
			gfCheck = SONG.gfVersion;
		}

		

		var curGf:String = '';
		switch (gfCheck)
		{
			case 'gf-car':
				curGf = 'gf-car';
			case 'gf-christmas':
				curGf = 'gf-christmas';
			case 'gfparachute':
				curGf = 'gfparachute';
			case 'gf-pixel':
				curGf = 'gf-pixel';
			case 'gfr':
				curGf = 'gfr';
			default:
				curGf = 'gf';
		}

		gf = new Character(400, 130, curGf);
		if(curSong == 'Ejected') {
			gf.scrollFactor.set(0.7, 0.7);
		}
		else {
			gf.scrollFactor.set(1, 1);
		}

		dad = new Character(100, 100, SONG.player2);

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
			case 'impostor':
				camPos.y += -200;
				camPos.x += 400;
				dad.y += 390;
				dad.x -= 100;
			case 'impostor3':
				camPos.set(gf.getMidpoint().x, gf.getMidpoint().y);
				camPos.y += -200;
				camPos.x += 400;
				dad.y += 350;
				dad.x -= 60;
			case 'black':
				camPos.y += -200;
				camPos.x += 400;
				dad.y += 50;
				dad.x -= 400;
			case 'impostorr':
				camPos.y += -200;
				camPos.x += 400;
				dad.y += 350;
				dad.x -= 60;
			case 'tomongus':
				dad.y += 570;
				dad.x += 250;
				camPos.set(gf.getMidpoint().x, gf.getMidpoint().y);
			case 'hamster':
				dad.y += 350;
				dad.x += 200;
			case 'crewmate':
				camPos.set(gf.getMidpoint().x, gf.getMidpoint().y);
				dad.y += 350;
				dad.x -= 60;
			case 'impostor2':
				camPos.y += -200;
				camPos.x += 400;
				dad.y += 390;
				dad.x -= 100;
			case 'spirit':
				if (FlxG.save.data.distractions)
				{
					// trailArea.scrollFactor.set();
					if (!PlayStateChangeables.Optimize)
					{
						var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
						// evilTrail.changeValuesEnabled(false, false, false, false);
						// evilTrail.changeGraphic()
						add(evilTrail);
					}
					// evilTrail.scrollFactor.set(1.1, 1.1);
				}

				dad.x -= 150;
				dad.y += 100;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
		}

		boyfriend = new Boyfriend(770, 450, SONG.player1);

		// REPOSITIONING PER STAGE
		switch (curStage)
		{
			case 'limo':
				boyfriend.y -= 220;
				boyfriend.x += 260;
				if (FlxG.save.data.distractions)
				{
					resetFastCar();
					add(fastCar);
				}

			case 'mall':
				boyfriend.x += 200;
			case 'reactor':
				gf.x -= 100;
			case 'defeat':
				gf.y -= 2000;

			case 'mallEvil':
				boyfriend.x += 320;
				dad.y -= 80;
			case 'ejected':
				boyfriend.setPosition(1008.6, 504);
				dad.setPosition(-775.75, 274.3);
				gf.setPosition(114.4, 78.45);
			case 'school':
				boyfriend.x += 270;
				boyfriend.y += 220;
				gf.x += 280;
				gf.y += 360;
			case 'schoolEvil':
				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
			case 'polus':
				dad.setPosition(-169.55, 264.9);
				gf.setPosition(206, -106.7);
				boyfriend.setPosition(751.7, 217.55);
				if(SONG.song.toLowerCase() == 'meltdown' || SONG.song.toLowerCase() == 'sabotage') {
					gf.y -= 100;
				}
		}

		if (!PlayStateChangeables.Optimize)
		{
			add(gf);

			// Shitty layering but whatev it works LOL

			if(SONG.song.toLowerCase() == 'meltdown') {
				//FUCKING DEAD
				add(deadBF);
			}
			

			add(dad);
			add(boyfriend);
			
			if(curStage == "ejected")
			{
				bfStartpos = new FlxPoint(boyfriend.x, boyfriend.y);
				gfStartpos = new FlxPoint(gf.x, gf.y);
				dadStartpos = new FlxPoint(dad.x, dad.y);
				for(i in 0...cloudScroll.members.length) {
					add(cloudScroll.members[i]);
				}
				add(cloudScroll);
				add(speedLines);
			}

			if (curStage == 'toogus')
			{
				stageFront2 = new FlxSprite(-850, 800).loadGraphic(Paths.image('table'));
				stageFront2.updateHitbox();
				stageFront2.antialiasing = true;
				stageFront2.scrollFactor.set(1, 1);
				stageFront2.setGraphicSize(Std.int(stageFront2.width * 1.6));

				stageFront3 = new FlxSprite(1600, 800).loadGraphic(Paths.image('table'));
				stageFront3.updateHitbox();
				stageFront3.antialiasing = true;
				stageFront3.scrollFactor.set(1, 1);
				stageFront3.setGraphicSize(Std.int(stageFront3.width * 1.6));
				stageFront3.flipX = true;
				add(stageFront2);
				add(stageFront3);

				stageFront2Dark = new FlxSprite(-850, 800).loadGraphic(Paths.image('tableDark'));
				stageFront2Dark.updateHitbox();
				stageFront2Dark.antialiasing = true;
				stageFront2Dark.scrollFactor.set(1, 1);
				stageFront2Dark.setGraphicSize(Std.int(stageFront2Dark.width * 1.6));
				stageFront2Dark.alpha = 0;

				stageFront3Dark = new FlxSprite(1600, 800).loadGraphic(Paths.image('tableDark'));
				stageFront3Dark.updateHitbox();
				stageFront3Dark.antialiasing = true;
				stageFront3Dark.scrollFactor.set(1, 1);
				stageFront3Dark.setGraphicSize(Std.int(stageFront3Dark.width * 1.6));
				stageFront3Dark.flipX = true;
				stageFront3Dark.alpha = 0;
				add(stageFront2Dark);
				add(stageFront3Dark);

				miraGradient = new FlxSprite(0,50).loadGraphic(Paths.image('MiraGradient'));
				miraGradient.setGraphicSize(Std.int(miraGradient.width * 1.4));
				miraGradient.antialiasing = true;
				miraGradient.scrollFactor.set(1, 1);
				miraGradient.active = false;
				miraGradient.alpha = 0;
				add(miraGradient);
			}

			
			

		}			

		if (loadRep)
		{
			FlxG.watch.addQuick('rep rpesses', repPresses);
			FlxG.watch.addQuick('rep releases', repReleases);
			// FlxG.watch.addQuick('Queued',inputsQueued);

			PlayStateChangeables.useDownscroll = rep.replay.isDownscroll;
			PlayStateChangeables.safeFrames = rep.replay.sf;
			PlayStateChangeables.botPlay = true;
		}

		trace('uh ' + PlayStateChangeables.safeFrames);

		trace("SF CALC: " + Math.floor((PlayStateChangeables.safeFrames / 60) * 1000));

		var greenImpostor:Bool = false;
		var talkingRight:Bool = false;

		if(SONG.song.toLowerCase() == 'sussus-toogus') {
			//bitch update
			greenImpostor = true;
			talkingRight = true;
		}

		if(SONG.song.toLowerCase() == 'lights-down') {
			//bitch update
			greenImpostor = true;
			talkingRight = false;
		}

		if(SONG.song.toLowerCase() == 'reactor') {
			//bitch update
			greenImpostor = true;
			talkingRight = true;
		}

		var doof:DialogueBox = new DialogueBox(talkingRight, dialogue, greenImpostor);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

		if (PlayStateChangeables.useDownscroll)
			strumLine.y = FlxG.height - 165;

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<FlxSprite>();
		cpuStrums = new FlxTypedGroup<FlxSprite>();

		generateStaticArrows(0);
		generateStaticArrows(1);

		// startCountdown();

		if (SONG.song == null)
			trace('song is null???');
		else
			trace('song looks gucci');

		generateSong(SONG.song);

		trace('generated');

		// add(strumLine);

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04 * (30 / (cast(Lib.current.getChildAt(0), Main)).getFPS()));
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		if(SONG.song.toLowerCase() == 'reactor') {
			camFollow.setPosition(gf.getGraphicMidpoint().x, gf.getGraphicMidpoint().y - 100);
		}

		if (FlxG.save.data.songPosition) // I dont wanna talk about this code :(
		{
			songPosBG = new FlxSprite(0, 10).loadGraphic(Paths.image('healthBar'));
			if (PlayStateChangeables.useDownscroll)
				songPosBG.y = FlxG.height * 0.9 + 45;
			songPosBG.screenCenter(X);
			songPosBG.scrollFactor.set();
			add(songPosBG);

			songPosBar = new FlxBar(songPosBG.x + 4, songPosBG.y + 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 8), Std.int(songPosBG.height - 8), this,
				'songPositionBar', 0, 90000);
			songPosBar.scrollFactor.set();
			songPosBar.createFilledBar(FlxColor.GRAY, FlxColor.LIME);
			add(songPosBar);

			var songName = new FlxText(songPosBG.x + (songPosBG.width / 2) - (SONG.song.length * 5), songPosBG.y, 0, SONG.song, 16);
			if (PlayStateChangeables.useDownscroll)
				songName.y -= 3;
			songName.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			songName.scrollFactor.set();
			add(songName);
			songName.cameras = [camHUD];
		}


		ass2 = new FlxSprite(0, FlxG.height * 1).loadGraphic(Paths.image('vignette')); 
		ass2.scrollFactor.set();
		ass2.screenCenter();
		if (curSong == 'Reactor')
		{
			add(ass2);
		}


		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.image('healthBar'));
		if (PlayStateChangeables.useDownscroll)
			healthBarBG.y = 50;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(FlxColor.fromString('#FF' + dad.playerColor), FlxColor.fromString('#FF' + boyfriend.playerColor));
		// healthBar
		add(healthBar);

		// Add Kade Engine watermark
		kadeEngineWatermark = new FlxText(4, healthBarBG.y
			+ 50, 0,
			SONG.song
			+ " - "
			+ CoolUtil.difficultyFromInt(storyDifficulty)
			+ (Main.watermarks ? " | KE " + MainMenuState.kadeEngineVer : ""), 16);
		kadeEngineWatermark.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		kadeEngineWatermark.scrollFactor.set();
		add(kadeEngineWatermark);
		if(isStoryMode) {
			kadeEngineWatermark.visible = false;
		}

		if (PlayStateChangeables.useDownscroll)
			kadeEngineWatermark.y = FlxG.height * 0.9 + 45;

		scoreTxt = new FlxText(FlxG.width / 2 - 235, healthBarBG.y + 50, 0, "", 20);

		scoreTxt.screenCenter(X);

		originalX = scoreTxt.x;

		scoreTxt.scrollFactor.set();

		scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		add(scoreTxt);

		if(isStoryMode) {
			scoreTxt.visible = false;
		}

		replayTxt = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (PlayStateChangeables.useDownscroll ? 100 : -100), 0, "REPLAY",
			20);
		replayTxt.setFormat(Paths.font("vcr.ttf"), 42, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		replayTxt.borderSize = 4;
		replayTxt.borderQuality = 2;
		replayTxt.scrollFactor.set();
		if (loadRep)
		{
			add(replayTxt);
		}
		// Literally copy-paste of the above, fu
		botPlayState = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (PlayStateChangeables.useDownscroll ? 100 : -100), 0,
			"", 20);
		botPlayState.setFormat(Paths.font("vcr.ttf"), 42, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botPlayState.scrollFactor.set();
		botPlayState.borderSize = 4;
		botPlayState.borderQuality = 2;
		if (PlayStateChangeables.botPlay && !loadRep)
			add(botPlayState);

		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);

		strumLineNotes.cameras = [camHUD];
		flashSprite.cameras = [camHUD];
		ass2.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		doof.cameras = [camHUD];
		if (FlxG.save.data.songPosition)
		{
			songPosBG.cameras = [camHUD];
			songPosBar.cameras = [camHUD];
		}
		kadeEngineWatermark.cameras = [camHUD];
		if (loadRep)
			replayTxt.cameras = [camHUD];

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;

		trace('starting');

		if (isStoryMode)
		{
			switch (StringTools.replace(curSong, " ", "-").toLowerCase())
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
					schoolIntro(doof);
				case 'sussus-moogus':
					susIntro(doof);
				case 'sabotage':
					susIntro(doof);
				case 'meltdown':
					susIntro(doof);
				case 'sussus-toogus':
					susIntro(doof);
				case 'lights-down':
					susIntro(doof);
				case 'reactor':
					susIntro(doof);
				case 'ejected':
					//hi im ziffy i wrote this
					//i know everytime i do an ingame cutscene it looks like this (bad)
					//but it works so go away please
					var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 5), Std.int(FlxG.height * 5), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					blackScreen.screenCenter();
					camFollow.setPosition(gf.getMidpoint().x, gf.getMidpoint().y - 1000);

					camHUD.visible = false;
					inCutscene = true;
					lockedCam = true;
					ejectedBoom = new FlxSprite();
					defaultCamZoom = 0.8;
					FlxG.camera.zoom = 0.8;			
					
					new FlxTimer().start(2, function(shine:FlxTimer) {
						var eyeShine:FlxSprite = new FlxSprite(0, 0);
						eyeShine.antialiasing = true;
						eyeShine.frames = Paths.getSparrowAtlas('ejected/eye_shine_thing', 'impostor');
						eyeShine.animation.addByPrefix('idle', 'eye shine thing lol instance 1', 24, false);
						eyeShine.animation.play('idle');
						eyeShine.updateHitbox();
						eyeShine.scrollFactor.set();
						eyeShine.screenCenter();
						eyeShine.x -= 500;
						add(eyeShine);
						FlxG.sound.play(Paths.sound('explosion', 'impostor'));
						new FlxTimer().start(1, function(tmr:FlxTimer)
						{						
							FlxG.camera.focusOn(camFollow.getPosition());
							ejectedBoom.frames = Paths.getSparrowAtlas('ejected/explosion', 'impostor');
							ejectedBoom.animation.addByPrefix('KABOOM', 'The instance 1', 24, false);
							ejectedBoom.updateHitbox();
							ejectedBoom.scrollFactor.set();
							ejectedBoom.screenCenter();
							ejectedBoom.scale.set(2, 2);
							ejectedBoom.animation.play('KABOOM');
							add(ejectedBoom);						
	
							new FlxTimer().start(0.7, function(tmr2:FlxTimer)
							{							
								blackScreen.destroy();	
								FlxTween.tween(FlxG.camera, {zoom: 0.45}, 2, {ease:FlxEase.quadInOut});
								FlxTween.tween(camFollow, {y: dad.getMidpoint().y}, 2, {ease: FlxEase.quadInOut});			
							});
	
							new FlxTimer().start(1.5, function(tmr3:FlxTimer)
							{							
								ejectedBoom.destroy();					
							});
	
	
							new FlxTimer().start(3, function(tmr2:FlxTimer)
							{						
								defaultCamZoom = 0.45;
								camHUD.visible = true;	
								lockedCam = false;
								inCutscene = false;
								startCountdown();				
							});
					});

					});
				case 'roses':
					FlxG.sound.play(Paths.sound('ANGRY'));
					schoolIntro(doof);
				case 'thorns':
					schoolIntro(doof);
				default:
					startCountdown();
			}
		}
		else
		{
			startCountdown();
		}

		if (!loadRep)
			rep = new Replay("na");

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, handleInput);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, releaseInput);
		super.create();
	}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();

		if (StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase() == 'roses'
			|| StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase() == 'thorns')
		{
			remove(black);

			if (StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase() == 'thorns')
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

					if (StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase() == 'thorns')
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

	function susIntro(?dialogueBox:DialogueBox):Void
		{
			FlxG.camera.fade(FlxColor.BLACK, 2, true, function()
			{
				if (dialogueBox != null)
					{
						inCutscene = true;
						add(dialogueBox);
					}
					else
						startCountdown();
			}, true);
		}

	var startTimer:FlxTimer;
	var perfectMode:Bool = false;

	var luaWiggles:Array<WiggleEffect> = [];

	#if windows
	public static var luaModchart:ModchartState = null;
	#end

	function startCountdown():Void
	{
		inCutscene = false;

		appearStaticArrows();
		//generateStaticArrows(0);
		//generateStaticArrows(1);

		if (startTime != 0)
		{
			var toBeRemoved = [];
			for(i in 0...unspawnNotes.length)
			{
				var dunceNote:Note = unspawnNotes[i];

				if (dunceNote.strumTime - startTime <= 0)
					toBeRemoved.push(dunceNote);
				else if (dunceNote.strumTime - startTime < 3500)
				{
					notes.add(dunceNote);

					if (dunceNote.mustPress)
						dunceNote.y = (playerStrums.members[Math.floor(Math.abs(dunceNote.noteData))].y
							+ 0.45 * (startTime - dunceNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
								2)) - dunceNote.noteYOff;
					else
						dunceNote.y = (strumLineNotes.members[Math.floor(Math.abs(dunceNote.noteData))].y
							+ 0.45 * (startTime - dunceNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
								2)) - dunceNote.noteYOff;
					toBeRemoved.push(dunceNote);
				}
			}

			for(i in toBeRemoved)
				unspawnNotes.remove(i);
		}

		#if windows
		// pre lowercasing the song name (startCountdown)
		var songLowercase = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase();
		switch (songLowercase)
		{
			case 'dad-battle':
				songLowercase = 'dadbattle';
			case 'philly-nice':
				songLowercase = 'philly';
		}
		if (executeModchart)
		{
			luaModchart = ModchartState.createModchartState();
			luaModchart.executeState('start', [songLowercase]);
		}
		#end

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			dad.dance();
			gf.dance();
			boyfriend.playAnim('idle');

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', "set", "go"]);
			introAssets.set('school', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);
			introAssets.set('schoolEvil', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);

			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";
			var inPixel:Bool = false;

			for (value in introAssets.keys())
			{
				if (value == curStage)
				{
					trace(value + " - " + curStage);
					introAlts = introAssets.get(value);
					if (curStage.contains('school'))
						inPixel = true;
				}
			}

			switch (swagCounter)

			{
				case 0:
					if(inPixel) {
						FlxG.sound.play(Paths.sound('intro3', 'impostor'), 0.6);
					}
					else {
						FlxG.sound.play(Paths.sound('intro3'), 0.6);
					}
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					ready.scrollFactor.set();
					ready.updateHitbox();

					if (curStage.startsWith('school'))
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
					if(inPixel) {
						FlxG.sound.play(Paths.sound('intro2', 'impostor'), 0.6);
					}
					else {
						FlxG.sound.play(Paths.sound('intro2'), 0.6);
					}
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					set.scrollFactor.set();

					if (curStage.startsWith('school'))
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
					if(inPixel) {
						FlxG.sound.play(Paths.sound('intro1', 'impostor'), 0.6);
					}
					else {
						FlxG.sound.play(Paths.sound('intro1'), 0.6);
					}
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					go.scrollFactor.set();

					if (curStage.startsWith('school'))
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
					if(inPixel) {
						FlxG.sound.play(Paths.sound('introGo', 'impostor'), 0.6);
					}
					else {
						FlxG.sound.play(Paths.sound('introGo'), 0.6);
					}
				case 4:
			}

			swagCounter += 1;
			// generateSong('fresh');
		}, 5);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	private function getKey(charCode:Int):String
	{
		for (key => value in FlxKey.fromStringMap)
		{
			if (charCode == value)
				return key;
		}
		return null;
	}

	var keys = [false, false, false, false];

	private function releaseInput(evt:KeyboardEvent):Void // handles releases
	{
		@:privateAccess
		var key = FlxKey.toStringMap.get(Keyboard.__convertKeyCode(evt.keyCode));

		var binds:Array<String> = [
			FlxG.save.data.leftBind,
			FlxG.save.data.downBind,
			FlxG.save.data.upBind,
			FlxG.save.data.rightBind
		];

		var data = -1;

		switch (evt.keyCode) // arrow keys
		{
			case 37:
				data = 0;
			case 40:
				data = 1;
			case 38:
				data = 2;
			case 39:
				data = 3;
		}

		for (i in 0...binds.length) // binds
		{
			if (binds[i].toLowerCase() == key.toLowerCase())
				data = i;
		}

		if (data == -1)
			return;

		keys[data] = false;
	}

	private function handleInput(evt:KeyboardEvent):Void
	{ // this actually handles press inputs

		if (PlayStateChangeables.botPlay || loadRep || paused)
			return;

		// first convert it from openfl to a flixel key code
		// then use FlxKey to get the key's name based off of the FlxKey dictionary
		// this makes it work for special characters

		@:privateAccess
		var key = FlxKey.toStringMap.get(Keyboard.__convertKeyCode(evt.keyCode));

		var binds:Array<String> = [
			FlxG.save.data.leftBind,
			FlxG.save.data.downBind,
			FlxG.save.data.upBind,
			FlxG.save.data.rightBind
		];

		var data = -1;

		switch (evt.keyCode) // arrow keys
		{
			case 37:
				data = 0;
			case 40:
				data = 1;
			case 38:
				data = 2;
			case 39:
				data = 3;
		}

		for (i in 0...binds.length) // binds
		{
			if (binds[i].toLowerCase() == key.toLowerCase())
				data = i;
		}
		if (data == -1)
		{
			trace("couldn't find a keybind with the code " + key);
			return;
		}
		if (keys[data])
		{
			trace("ur already holding " + key);
			return;
		}

		keys[data] = true;

		var ana = new Ana(Conductor.songPosition, null, false, "miss", data);

		var dataNotes = [];
		notes.forEachAlive(function(daNote:Note)
		{
			if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && daNote.noteData == data)
				dataNotes.push(daNote);
		}); // Collect notes that can be hit

		dataNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime)); // sort by the earliest note

		if (dataNotes.length != 0)
		{
			var coolNote = null;

			for (i in dataNotes)
				if (!i.isSustainNote)
				{
					coolNote = i;
					break;
				}

			if (coolNote == null) // Note is null, which means it's probably a sustain note. Update will handle this (HOPEFULLY???)
			{
				return;
			}

			if (dataNotes.length > 1) // stacked notes or really close ones
			{
				for (i in 0...dataNotes.length)
				{
					if (i == 0) // skip the first note
						continue;

					var note = dataNotes[i];

					if (!note.isSustainNote && (note.strumTime - coolNote.strumTime) < 2)
					{
						trace('found a stacked/really close note ' + (note.strumTime - coolNote.strumTime));
						// just fuckin remove it since it's a stacked note and shouldn't be there
						note.kill();
						notes.remove(note, true);
						note.destroy();
					}
				}
			}

			goodNoteHit(coolNote);
			var noteDiff:Float = -(coolNote.strumTime - Conductor.songPosition);
			ana.hit = true;
			ana.hitJudge = Ratings.CalculateRating(noteDiff, Math.floor((PlayStateChangeables.safeFrames / 60) * 1000));
			ana.nearestNote = [coolNote.strumTime, coolNote.noteData, coolNote.sustainLength];
		}
		else if (!FlxG.save.data.ghost && songStarted)
		{
			noteMiss(data, null);
			ana.hit = false;
			ana.hitJudge = "shit";
			ana.nearestNote = [];
			health -= 0.10;
		}
	}

	var songStarted = false;

	function startSong():Void
	{
		startingSong = false;
		songStarted = true;
		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!paused)
		{
			#if sys
			if (!isStoryMode && isSM)
			{
				trace("Loading " + pathToSm + "/" + sm.header.MUSIC);
				var bytes = File.getBytes(pathToSm + "/" + sm.header.MUSIC);
				var sound = new Sound();
				sound.loadCompressedDataFromByteArray(bytes.getData(), bytes.length);
				FlxG.sound.playMusic(sound);
			}
			else
				FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
			#else
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
			#end
		}

		if(SONG.song.toLowerCase() == 'sabotage' && isStoryMode) {
			FlxG.sound.music.onComplete = endSabotage;
		}
		else if (SONG.song.toLowerCase() == 'sussus-moogus' && isStoryMode) {
			FlxG.sound.music.onComplete = endMoogus;
		}
		else {
			FlxG.sound.music.onComplete = endSong;
		}
		vocals.play();

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		if (FlxG.save.data.songPosition)
		{
			remove(songPosBG);
			remove(songPosBar);
			remove(songName);

			songPosBG = new FlxSprite(0, 10).loadGraphic(Paths.image('healthBar'));
			if (PlayStateChangeables.useDownscroll)
				songPosBG.y = FlxG.height * 0.9 + 45;
			songPosBG.screenCenter(X);
			songPosBG.scrollFactor.set();
			add(songPosBG);

			songPosBar = new FlxBar(songPosBG.x
				+ 4, songPosBG.y
				+ 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 8), Std.int(songPosBG.height - 8), this,
				'songPositionBar', 0, songLength
				- 1000);
			songPosBar.numDivisions = 1000;
			songPosBar.scrollFactor.set();
			songPosBar.createFilledBar(FlxColor.GRAY, FlxColor.LIME);
			add(songPosBar);

			var songName = new FlxText(songPosBG.x + (songPosBG.width / 2) - (SONG.song.length * 5), songPosBG.y, 0, SONG.song, 16);
			if (PlayStateChangeables.useDownscroll)
				songName.y -= 3;
			songName.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			songName.scrollFactor.set();
			add(songName);

			songPosBG.cameras = [camHUD];
			songPosBar.cameras = [camHUD];
			songName.cameras = [camHUD];
		}

		// Song check real quick
		switch (curSong)
		{
			case 'Bopeebo' | 'Philly Nice' | 'Blammed' | 'Cocoa' | 'Eggnog':
				allowedToHeadbang = true;
			default:
				allowedToHeadbang = false;
		}

		if (useVideo)
			GlobalVideo.get().resume();

		#if windows
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText
			+ " "
			+ SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ Ratings.GenerateLetterRank(accuracy),
			"\nAcc: "
			+ HelperFunctions.truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC);
		#end

		FlxG.sound.music.time = startTime;
		vocals.time = startTime;
		Conductor.songPosition = startTime;
		startTime = 0;

		for(i in 0...unspawnNotes.length)
			if (unspawnNotes[i].strumTime < startTime)
				unspawnNotes.remove(unspawnNotes[i]);
	}

	var debugNum:Int = 0;

	public function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		#if sys
		if (SONG.needsVoices && !isSM)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();
		#else
		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();
		#end

		trace('loaded vocals');

		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		// Per song offset check
		#if windows
		// pre lowercasing the song name (generateSong)
		var songLowercase = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase();
		switch (songLowercase)
		{
			case 'dad-battle':
				songLowercase = 'dadbattle';
			case 'philly-nice':
				songLowercase = 'philly';
		}

		var songPath = 'assets/data/' + songLowercase + '/';
		
		#if sys
		if (isSM && !isStoryMode)
			songPath = pathToSm;
		#end

		for (file in sys.FileSystem.readDirectory(songPath))
		{
			var path = haxe.io.Path.join([songPath, file]);
			if (!sys.FileSystem.isDirectory(path))
			{
				if (path.endsWith('.offset'))
				{
					trace('Found offset file: ' + path);
					songOffset = Std.parseFloat(file.substring(0, file.indexOf('.off')));
					break;
				}
				else
				{
					trace('Offset file not found. Creating one @: ' + songPath);
					sys.io.File.saveContent(songPath + songOffset + '.offset', '');
				}
			}
		}
		#end
		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped


		for (section in noteData)
		{
			var coolSection:Int = Std.int(section.lengthInSteps / 4);

			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0] + FlxG.save.data.offset + songOffset;
				if (daStrumTime < 0)
					daStrumTime = 0;
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);

				if (!gottaHitNote && PlayStateChangeables.Optimize)
					continue;

				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				if (susLength > 0)
					swagNote.isParent = true;

				var type = 0;

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true);
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);

					sustainNote.mustPress = gottaHitNote;

					if (sustainNote.mustPress)
					{
						sustainNote.x += FlxG.width / 2; // general offset
					}

					sustainNote.parent = swagNote;
					swagNote.children.push(sustainNote);
					sustainNote.spotInLine = type;
					type++;
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
			}
			daBeats += 1;
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y);

			// defaults if no noteStyle was found in chart
			var noteTypeCheck:String = 'normal';

			if (PlayStateChangeables.Optimize && player == 0)
				continue;

			if (SONG.noteStyle == null)
			{
				switch (storyWeek)
				{
					case 3:
						noteTypeCheck = 'pixel';
				}
			}
			else
			{
				noteTypeCheck = SONG.noteStyle;
			}

			switch (noteTypeCheck)
			{
				case 'pixel':
					babyArrow.loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels','shared'), true, 17, 17);
					babyArrow.animation.add('green', [6]);
					babyArrow.animation.add('red', [7]);
					babyArrow.animation.add('blue', [5]);
					babyArrow.animation.add('purplel', [4]);

					babyArrow.setGraphicSize(Std.int(babyArrow.width * daPixelZoom));
					babyArrow.updateHitbox();
					babyArrow.antialiasing = false;

					switch (Math.abs(i))
					{
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.add('static', [2]);
							babyArrow.animation.add('pressed', [6, 10], 12, false);
							babyArrow.animation.add('confirm', [14, 18], 12, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.add('static', [3]);
							babyArrow.animation.add('pressed', [7, 11], 12, false);
							babyArrow.animation.add('confirm', [15, 19], 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.add('static', [1]);
							babyArrow.animation.add('pressed', [5, 9], 12, false);
							babyArrow.animation.add('confirm', [13, 17], 24, false);
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.add('static', [0]);
							babyArrow.animation.add('pressed', [4, 8], 12, false);
							babyArrow.animation.add('confirm', [12, 16], 24, false);
					}

				default:
					babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets');
					for (j in 0...4)
					{
						babyArrow.animation.addByPrefix(dataColor[j], 'arrow' + dataSuffix[j]);	
					}

					var lowerDir:String = dataSuffix[i].toLowerCase();

					babyArrow.animation.addByPrefix('static', 'arrow' + dataSuffix[i]);
					babyArrow.animation.addByPrefix('pressed', lowerDir + ' press', 24, false);
					babyArrow.animation.addByPrefix('confirm', lowerDir + ' confirm', 24, false);

					babyArrow.x += Note.swagWidth * i;

					if(FlxG.save.data.antialiasing)
						{
							babyArrow.antialiasing = true;
						}
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			babyArrow.alpha = 0;
			if (!isStoryMode)
			{
				babyArrow.y -= 10;
				//babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			babyArrow.ID = i;

			switch (player)
			{
				case 0:
					cpuStrums.add(babyArrow);
				case 1:
					playerStrums.add(babyArrow);
			}

			babyArrow.animation.play('static');
			babyArrow.x += 50;
			babyArrow.x += ((FlxG.width / 2) * player);

			if (PlayStateChangeables.Optimize)
				babyArrow.x -= 275;

			cpuStrums.forEach(function(spr:FlxSprite)
			{
				spr.centerOffsets(); // CPU arrows start out slightly off-center
			});

			strumLineNotes.add(babyArrow);
		}
	}

	private function appearStaticArrows():Void
	{
		strumLineNotes.forEach(function(babyArrow:FlxSprite)
		{
			if (isStoryMode)
				babyArrow.alpha = 1;
		});
	}

	function tweenCamIn():Void
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
				vocals.pause();
			}

			#if windows
			DiscordClient.changePresence("PAUSED on "
				+ SONG.song
				+ " ("
				+ storyDifficultyText
				+ ") "
				+ Ratings.GenerateLetterRank(accuracy),
				"Acc: "
				+ HelperFunctions.truncateFloat(accuracy, 2)
				+ "% | Score: "
				+ songScore
				+ " | Misses: "
				+ misses, iconRPC);
			#end
			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
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

			#if windows
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
					+ HelperFunctions.truncateFloat(accuracy, 2)
					+ "% | Score: "
					+ songScore
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
	}

	function resyncVocals():Void
	{
		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();

		#if windows
		DiscordClient.changePresence(detailsText
			+ " "
			+ SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ Ratings.GenerateLetterRank(accuracy),
			"\nAcc: "
			+ HelperFunctions.truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC);
		#end
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var nps:Int = 0;
	var maxNPS:Int = 0;

	public static var songRate = 1.5;

	public var stopUpdate = false;
	public var removedVideo = false;

	public var currentBPM = 0;

	public var updateFrame = 0;

	public var tweeningChar:Bool = false;

	override public function update(elapsed:Float)
	{
		#if !debug
		perfectMode = false;
		#end

		if(curStage == "ejected")
		{
			if(!inCutscene)
				camGame.shake(0.002, 0.1);

			if(!tweeningChar && !inCutscene)
			{
				tweeningChar = true;
				FlxTween.tween(boyfriend, {x: FlxG.random.float(bfStartpos.x - 15, bfStartpos.x + 15), y: FlxG.random.float(bfStartpos.y - 15, bfStartpos.y + 15)}, 0.4, {
					ease: FlxEase.smoothStepInOut,
					onComplete: function(twn:FlxTween)
					{
						tweeningChar = false;
					}
				});
				FlxTween.tween(gf, {x: FlxG.random.float(gfStartpos.x - 10, gfStartpos.x + 10), y: FlxG.random.float(gfStartpos.y - 10, gfStartpos.y + 10)}, 0.4, {
					ease: FlxEase.smoothStepInOut});
				FlxTween.tween(dad, {x: FlxG.random.float(dadStartpos.x - 15, dadStartpos.x + 15), y: FlxG.random.float(dadStartpos.y - 15, dadStartpos.y + 15)}, 0.4, {
					ease: FlxEase.smoothStepInOut});
			}
		}

		if (updateFrame == 4)
			{
				TimingStruct.clearTimings();
	
					var currentIndex = 0;
					for (i in SONG.eventObjects)
					{
						if (i.type == "BPM Change")
						{
							var beat:Float = i.position;
	
							var endBeat:Float = Math.POSITIVE_INFINITY;
	
							TimingStruct.addTiming(beat,i.value,endBeat, 0); // offset in this case = start time since we don't have a offset
							
							if (currentIndex != 0)
							{
								var data = TimingStruct.AllTimings[currentIndex - 1];
								data.endBeat = beat;
								data.length = (data.endBeat - data.startBeat) / (data.bpm / 60);
								TimingStruct.AllTimings[currentIndex].startTime = data.startTime + data.length;
							}
	
							currentIndex++;
						}
					}
					updateFrame++;
			}
			else if (updateFrame != 5)
				updateFrame++;
	

			var timingSeg = TimingStruct.getTimingAtTimestamp(Conductor.songPosition);
	
			if (timingSeg != null)
			{
	
				var timingSegBpm = timingSeg.bpm;
	
				if (timingSegBpm != Conductor.bpm)
				{
					trace("BPM CHANGE to " + timingSegBpm);
					Conductor.changeBPM(timingSegBpm, false);
				}
	
			}

		var newScroll = PlayStateChangeables.scrollSpeed;

		/*for(i in SONG.eventObjects)
		{
			switch(i.type)
			{
				case "Scroll Speed Change":
					if (i.position < curDecimalBeat)
						newScroll = i.value;
			}
		}*/

		if(curSong == 'Reactor') {
			if(orb != null) {
				orb.scale.x = FlxMath.lerp(0.7, orb.scale.x, 0.90);
				orb.scale.y = FlxMath.lerp(0.7, orb.scale.y, 0.90);
				orb.alpha = FlxMath.lerp(0.96, orb.alpha, 0.90);
				ass2.alpha = FlxMath.lerp(1, ass2.alpha, 0.90);
			}
		}

		PlayStateChangeables.scrollSpeed = newScroll;
	
		if (PlayStateChangeables.botPlay && FlxG.keys.justPressed.ONE)
			camHUD.visible = !camHUD.visible;

		if (useVideo && GlobalVideo.get() != null && !stopUpdate)
		{
			if (GlobalVideo.get().ended && !removedVideo)
			{
				remove(videoSprite);
				FlxG.stage.window.onFocusOut.remove(focusOut);
				FlxG.stage.window.onFocusIn.remove(focusIn);
				removedVideo = true;
			}
		}

		#if windows
		if (executeModchart && luaModchart != null && songStarted)
		{
			luaModchart.setVar('songPos', Conductor.songPosition);
			luaModchart.setVar('hudZoom', camHUD.zoom);
			luaModchart.setVar('curBeat', HelperFunctions.truncateFloat(curDecimalBeat,3));
			luaModchart.setVar('cameraZoom', FlxG.camera.zoom);
			luaModchart.executeState('update', [elapsed]);

			for (key => value in luaModchart.luaWiggles) 
			{
				trace('wiggle le gaming');
				value.update(elapsed);
			}

			/*for (i in 0...strumLineNotes.length) {
				var member = strumLineNotes.members[i];
				member.x = luaModchart.getVar("strum" + i + "X", "float");
				member.y = luaModchart.getVar("strum" + i + "Y", "float");
				member.angle = luaModchart.getVar("strum" + i + "Angle", "float");
			}*/

			FlxG.camera.angle = luaModchart.getVar('cameraAngle', 'float');
			camHUD.angle = luaModchart.getVar('camHudAngle', 'float');

			if (luaModchart.getVar("showOnlyStrums", 'bool'))
			{
				healthBarBG.visible = false;
				kadeEngineWatermark.visible = false;
				healthBar.visible = false;
				iconP1.visible = false;
				iconP2.visible = false;
				scoreTxt.visible = false;
			}
			else
			{
				healthBarBG.visible = true;
				kadeEngineWatermark.visible = true;
				healthBar.visible = true;
				iconP1.visible = true;
				iconP2.visible = true;
				scoreTxt.visible = true;
			}

			var p1 = luaModchart.getVar("strumLine1Visible", 'bool');
			var p2 = luaModchart.getVar("strumLine2Visible", 'bool');

			for (i in 0...4)
			{
				strumLineNotes.members[i].visible = p1;
				if (i <= playerStrums.length)
					playerStrums.members[i].visible = p2;
			}
		}
		#end

		// reverse iterate to remove oldest notes first and not invalidate the iteration
		// stop iteration as soon as a note is not removed
		// all notes should be kept in the correct order and this is optimal, safe to do every frame/update
		{
			var balls = notesHitArray.length - 1;
			while (balls >= 0)
			{
				var cock:Date = notesHitArray[balls];
				if (cock != null && cock.getTime() + 1000 < Date.now().getTime())
					notesHitArray.remove(cock);
				else
					balls = 0;
				balls--;
			}
			nps = notesHitArray.length;
			if (nps > maxNPS)
				maxNPS = nps;
		}

		if (FlxG.keys.justPressed.NINE)
				iconP1.swapOldIcon();

		switch (curStage)
		{
			case 'philly':
				if (trainMoving && !PlayStateChangeables.Optimize)
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}
				// phillyCityLights.members[curLight].alpha -= (Conductor.crochet / 1000) * FlxG.elapsed;
		}

		if(curStage == 'ejected') {
			//make sure that the clouds exist
			if(cloudScroll.members.length == 3) {
				for(i in 0...cloudScroll.members.length) {					
					cloudScroll.members[i].y -= speedPass[i] / (cast(Lib.current.getChildAt(0), Main)).getFPS();
					if(cloudScroll.members[i].y < -1789.65) {
						//im not using flxbackdrops so this is how we're doing things today
						var randomScale = FlxG.random.float(1.5, 2.2);
						var randomScroll = FlxG.random.float(1, 1.3);

						speedPass[i] = FlxG.random.float(9000, 11000);

						cloudScroll.members[i].scale.set(randomScale, randomScale);
						cloudScroll.members[i].scrollFactor.set(randomScroll, randomScroll);
						cloudScroll.members[i].x = FlxG.random.float(-3578.95, 3259.6);
						cloudScroll.members[i].y = 2196.15;
					}
				}
			}
			if(farClouds.members.length == 7) {
				for(i in 0...farClouds.members.length) {					
					farClouds.members[i].y -= farSpeedPass[i] / (cast(Lib.current.getChildAt(0), Main)).getFPS();
					if(farClouds.members[i].y < -1614) {
						var randomScale = FlxG.random.float(0.2, 0.5);
						var randomScroll = FlxG.random.float(0.2, 0.4);

						farSpeedPass[i] = FlxG.random.float(9000, 11000);

						farClouds.members[i].scale.set(randomScale, randomScale);
						farClouds.members[i].scrollFactor.set(randomScroll, randomScroll);
						farClouds.members[i].x = FlxG.random.float(-2737.85, 3485.4);
						farClouds.members[i].y = 1738.6;
					}
				}
			}
			//AAAAAAAAAAAAAAAAAAAA			
			if(leftBuildings.length > 0) {
				for(i in 0...leftBuildings.length) {
					leftBuildings[i].y = middleBuildings[i].y + 5888;
				}
			}
			if(middleBuildings.length > 0) {
				for(i in 0...middleBuildings.length) {
					if(middleBuildings[i].y < -11759.9) {
						middleBuildings[i].y = 3190.5;
						middleBuildings[i].animation.play(FlxG.random.bool(50) ? '1' : '2');
					}			
					middleBuildings[i].y -= 9000 / (cast(Lib.current.getChildAt(0), Main)).getFPS();
				}
			}
			if(rightBuildings.length > 0) {
				for(i in 0...rightBuildings.length) {
					rightBuildings[i].y = leftBuildings[i].y;
				}
			}
			speedLines.y -= 9000 / (cast(Lib.current.getChildAt(0), Main)).getFPS();
			if(fgCloud != null) {
				fgCloud.y -= 0.01;
			}
		}

		super.update(elapsed);

		scoreTxt.text = Ratings.CalculateRanking(songScore, songScoreDef, nps, maxNPS, accuracy);

		var lengthInPx = scoreTxt.textField.length * scoreTxt.frameHeight; // bad way but does more or less a better job

		scoreTxt.x = (originalX - (lengthInPx / 2)) + 335;


		

		if (controls.PAUSE && startedCountdown && canPause && !cannotDie)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			// 1 / 1000 chance for Gitaroo Man easter egg
			if (FlxG.random.bool(0.1))
			{
				trace('GITAROO MAN EASTER EGG');
				FlxG.switchState(new GitarooPause());
			}
			else
				openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}

		if (FlxG.keys.justPressed.SEVEN)
		{
			if (useVideo)
			{
				GlobalVideo.get().stop();
				remove(videoSprite);
				#if sys
				FlxG.stage.window.onFocusOut.remove(focusOut);
				FlxG.stage.window.onFocusIn.remove(focusIn);
				#end
				removedVideo = true;
			}
			cannotDie = true;
			#if windows
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
			FlxG.switchState(new ChartingState());
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
			#if windows
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			#end
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, 0.50)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, 0.50)));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if (health > 2)
			health = 2;
		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		/* if (FlxG.keys.justPressed.NINE)
			FlxG.switchState(new Charting()); */

		#if debug
		if (FlxG.keys.justPressed.SIX)
		{
			if (useVideo)
			{
				GlobalVideo.get().stop();
				remove(videoSprite);
				FlxG.stage.window.onFocusOut.remove(focusOut);
				FlxG.stage.window.onFocusIn.remove(focusIn);
				removedVideo = true;
			}

			FlxG.switchState(new AnimationDebug(SONG.player2));
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
			#if windows
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			#end
		}

		if (FlxG.keys.justPressed.ZERO)
		{
			FlxG.switchState(new AnimationDebug(SONG.player1));
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
			#if windows
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			#end
		}
		
		if(FlxG.keys.justPressed.TWO) { //Go 10 seconds into the future, credit: Shadow Mario#9396
			if (!usedTimeTravel && Conductor.songPosition + 10000 < FlxG.sound.music.length) 
			{
				usedTimeTravel = true;
				FlxG.sound.music.pause();
				vocals.pause();
				Conductor.songPosition += 10000;
				notes.forEachAlive(function(daNote:Note)
				{
					if(daNote.strumTime - 500 < Conductor.songPosition) {
						daNote.active = false;
						daNote.visible = false;

					
						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				});
				for (i in 0...unspawnNotes.length) {
					var daNote:Note = unspawnNotes[0];
					if(daNote.strumTime - 500 >= Conductor.songPosition) {
						break;
					}
					unspawnNotes.splice(unspawnNotes.indexOf(daNote), 1);
				}

				FlxG.sound.music.time = Conductor.songPosition;
				FlxG.sound.music.play();

				vocals.time = Conductor.songPosition;
				vocals.play();
				new FlxTimer().start(0.5, function(tmr:FlxTimer)
					{
						usedTimeTravel = false;
					});
			}
		}
		#end

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
			// Conductor.songPosition = FlxG.sound.music.time;
			Conductor.songPosition += FlxG.elapsed * 1000;
			/*@:privateAccess
				{
					FlxG.sound.music._channel.
			}*/
			songPositionBar = Conductor.songPosition;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			// Make sure Girlfriend cheers only for certain songs
			if (allowedToHeadbang)
			{
				// Don't animate GF if something else is already animating her (eg. train passing)
				if (gf.animation.curAnim.name == 'danceLeft'
					|| gf.animation.curAnim.name == 'danceRight'
					|| gf.animation.curAnim.name == 'idle')
				{
					// Per song treatment since some songs will only have the 'Hey' at certain times
					switch (curSong)
					{
						case 'Philly Nice':
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



			#if windows
			if (luaModchart != null)
				luaModchart.setVar("mustHit", PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);
			#end

			if (camFollow.x != dad.getMidpoint().x + 150 && !PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
			{
				var offsetX = 0;
				var offsetY = 0;
				#if windows
				if (luaModchart != null)
				{
					offsetX = luaModchart.getVar("followXOffset", "float");
					offsetY = luaModchart.getVar("followYOffset", "float");
				}
				#end
				if(curSong != 'Reactor' && !lockedCam) {
					camFollow.setPosition(dad.getMidpoint().x + 150 + offsetX, dad.getMidpoint().y - 100 + offsetY);
				}
				#if windows
				if (luaModchart != null)
					luaModchart.executeState('playerTwoTurn', []);
				#end
				// camFollow.setPosition(lucky.getMidpoint().x - 120, lucky.getMidpoint().y + 210);

				if(curSong != 'Reactor') {
					switch (dad.curCharacter)
					{
						case 'tomongus':
							camFollow.y = dad.getMidpoint().y - 240;
							camFollow.x = dad.getMidpoint().x - 50;
						case 'black':
							camFollow.y = dad.getMidpoint().y - 200;
							camFollow.x = dad.getMidpoint().x - 400;
						case 'hamster':
							camFollow.y = dad.getMidpoint().y - 230;
							camFollow.x = dad.getMidpoint().x - 200;
						case 'senpai' | 'senpai-angry':
							camFollow.y = dad.getMidpoint().y - 430;
							camFollow.x = dad.getMidpoint().x - 100;
						case 'impostorr':
							camFollow.x = dad.getMidpoint().x + 245;
							camFollow.y = dad.getMidpoint().y - 350;
					}
				}
			}

			if (PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && camFollow.x != boyfriend.getMidpoint().x - 100)
			{
				var offsetX = 0;
				var offsetY = 0;
				#if windows
				if (luaModchart != null)
				{
					offsetX = luaModchart.getVar("followXOffset", "float");
					offsetY = luaModchart.getVar("followYOffset", "float");
				}
				#end
				if(curSong != 'Reactor' && !lockedCam) {
					camFollow.setPosition(boyfriend.getMidpoint().x - 100 + offsetX, boyfriend.getMidpoint().y - 100 + offsetY);
				}

				#if windows
				if (luaModchart != null)
					luaModchart.executeState('playerOneTurn', []);
				#end

				if(curSong != 'Reactor') {
					switch (curStage)
					{
						case 'limo':
							camFollow.x = boyfriend.getMidpoint().x - 300;
						case 'mall':
							camFollow.y = boyfriend.getMidpoint().y - 200;
						case 'school':
							camFollow.x = boyfriend.getMidpoint().x - 200;
							camFollow.y = boyfriend.getMidpoint().y - 200;
						case 'schoolEvil':
							camFollow.x = boyfriend.getMidpoint().x - 200;
							camFollow.y = boyfriend.getMidpoint().y - 200;
					}
				}
			}
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
		}

		FlxG.watch.addQuick("curBPM", Conductor.bpm);
		FlxG.watch.addQuick("Closest Note", (unspawnNotes.length != 0 ? unspawnNotes[0].strumTime - Conductor.songPosition : "No note"));

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		if (curSong == 'Fresh')
		{
			switch (curBeat)
			{
				case 16:
					camZooming = true;
					gfSpeed = 2;
				case 48:
					gfSpeed = 1;
				case 80:
					gfSpeed = 2;
				case 112:
					gfSpeed = 1;
				case 163:
					// FlxG.sound.music.stop();
					// FlxG.switchState(new TitleState());
			}
		}

		if (curSong == 'Bopeebo')
		{
			switch (curBeat)
			{
				case 128, 129, 130:
					vocals.volume = 0;
					// FlxG.sound.music.stop();
					// FlxG.switchState(new PlayState());
			}
		}

		if(curSong == "Defeat" && misses == 1 && camHUD.visible)
		{
			camSustains.visible = false;
			camNotes.visible = false;
			camHUD.visible = false;
			inCutscene = true;
			canPause = false;
			camZooming = false;
			startedCountdown = false;
			generatedMusic = false;
	
			vocals.stop();

			camFollow.setPosition(dad.getMidpoint().x - 400, dad.getMidpoint().y - 170);	
			dad.changeHoldState(true);
			boyfriend.changeHoldState(true);
			dad.playAnim('death');

			camFollow.y = dad.getMidpoint().y - 200;
			camFollow.x = dad.getMidpoint().x - 450;

			FlxG.sound.play(Paths.sound('black-death', 'impostor'));
			
			FlxTween.tween(FlxG.camera, {zoom: 1.2}, 1.5, {ease: FlxEase.circOut});

			new FlxTimer().start(0.6, function(tmr:FlxTimer)
			{
				boyfriend.stunned = true;

				persistentUpdate = false;
				persistentDraw = false;
				paused = true;

				vocals.stop();
				FlxG.sound.music.stop();

				openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

				#if windows
				// Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence("GAME OVER -- "
					+ SONG.song
					+ " ("
					+ storyDifficultyText
					+ ") "
					+ Ratings.GenerateLetterRank(accuracy),
					"\nAcc: "
					+ HelperFunctions.truncateFloat(accuracy, 2)
					+ "% | Score: "
					+ songScore
					+ " | Misses: "
					+ misses, iconRPC);
				#end

				// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			});
		}

		if (health <= 0 && !cannotDie)
		{
			if (!usedTimeTravel) 
			{
				boyfriend.stunned = true;

				persistentUpdate = false;
				persistentDraw = false;
				paused = true;

				vocals.stop();
				FlxG.sound.music.stop();

				openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

				#if windows
				// Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence("GAME OVER -- "
					+ SONG.song
					+ " ("
					+ storyDifficultyText
					+ ") "
					+ Ratings.GenerateLetterRank(accuracy),
					"\nAcc: "
					+ HelperFunctions.truncateFloat(accuracy, 2)
					+ "% | Score: "
					+ songScore
					+ " | Misses: "
					+ misses, iconRPC);
				#end

				// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			}
			else
				health = 1;
		}
		if (!inCutscene && FlxG.save.data.resetButton)
		{
			if (FlxG.keys.justPressed.R)
			{
				boyfriend.stunned = true;

				persistentUpdate = false;
				persistentDraw = false;
				paused = true;

				vocals.stop();
				FlxG.sound.music.stop();

				openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

				#if windows
				// Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence("GAME OVER -- "
					+ SONG.song
					+ " ("
					+ storyDifficultyText
					+ ") "
					+ Ratings.GenerateLetterRank(accuracy),
					"\nAcc: "
					+ HelperFunctions.truncateFloat(accuracy, 2)
					+ "% | Score: "
					+ songScore
					+ " | Misses: "
					+ misses, iconRPC);
				#end

				// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			}
		}

		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 3500)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);
				if (!dunceNote.isSustainNote)
					dunceNote.cameras = [camNotes];
				else
					dunceNote.cameras = [camSustains];

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
			var holdArray:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];

			notes.forEachAlive(function(daNote:Note)
			{
				// instead of doing stupid y > FlxG.height
				// we be men and actually calculate the time :)
				if (daNote.tooLate)
				{
					daNote.active = false;
					daNote.visible = false;
				}
				else
				{
					daNote.visible = true;
					daNote.active = true;
				}

				if (!daNote.modifiedByLua)
				{
					if (PlayStateChangeables.useDownscroll)
					{
						if (daNote.mustPress)
							daNote.y = (playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y
								+ 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
									2)) - daNote.noteYOff;
						else
							daNote.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
								+ 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
									2)) - daNote.noteYOff;
						if (daNote.isSustainNote)
						{
							// Remember = minus makes notes go up, plus makes them go down
							if (daNote.animation.curAnim.name.endsWith('end') && daNote.prevNote != null)
								daNote.y += daNote.prevNote.height;
							else
								daNote.y += daNote.height / 2;

							// If not in botplay, only clip sustain notes when properly hit, botplay gets to clip it everytime
							if (!PlayStateChangeables.botPlay)
							{
								if ((!daNote.mustPress || daNote.wasGoodHit || daNote.prevNote.wasGoodHit && !daNote.canBeHit)
									&& daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= (strumLine.y + Note.swagWidth / 2))
								{
									// Clip to strumline
									var swagRect = new FlxRect(0, 0, daNote.frameWidth * 2, daNote.frameHeight * 2);
									swagRect.height = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
										+ Note.swagWidth / 2
										- daNote.y) / daNote.scale.y;
									swagRect.y = daNote.frameHeight - swagRect.height;

									daNote.clipRect = swagRect;
								}
							}
							else
							{
								var swagRect = new FlxRect(0, 0, daNote.frameWidth * 2, daNote.frameHeight * 2);
								swagRect.height = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
									+ Note.swagWidth / 2
									- daNote.y) / daNote.scale.y;
								swagRect.y = daNote.frameHeight - swagRect.height;

								daNote.clipRect = swagRect;
							}
						}
					}
					else
					{
						if (daNote.mustPress)
							daNote.y = (playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y
								- 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
									2)) + daNote.noteYOff;
						else
							daNote.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
								- 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
									2)) + daNote.noteYOff;
						if (daNote.isSustainNote)
						{
							daNote.y -= daNote.height / 2;

							if (!PlayStateChangeables.botPlay)
							{
								if ((!daNote.mustPress || daNote.wasGoodHit || daNote.prevNote.wasGoodHit && !daNote.canBeHit)
									&& daNote.y + daNote.offset.y * daNote.scale.y <= (strumLine.y + Note.swagWidth / 2))
								{
									// Clip to strumline
									var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
									swagRect.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
										+ Note.swagWidth / 2
										- daNote.y) / daNote.scale.y;
									swagRect.height -= swagRect.y;

									daNote.clipRect = swagRect;
								}
							}
							else
							{
								var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
								swagRect.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
									+ Note.swagWidth / 2
									- daNote.y) / daNote.scale.y;
								swagRect.height -= swagRect.y;

								daNote.clipRect = swagRect;
							}
						}
					}
				}

				if (!daNote.mustPress && daNote.wasGoodHit)
				{
					if (SONG.song != 'Tutorial')
						camZooming = true;

					var altAnim:String = "";

					if (SONG.notes[Math.floor(curStep / 16)] != null)
					{
						if (SONG.notes[Math.floor(curStep / 16)].altAnim)
							altAnim = '-alt';
					}
					
					// Accessing the animation name directly to play it
					var singData:Int = Std.int(Math.abs(daNote.noteData));
					dad.playAnim('sing' + dataSuffix[singData] + altAnim, true);

					if (FlxG.save.data.cpuStrums)
					{
						cpuStrums.forEach(function(spr:FlxSprite)
						{
							if (Math.abs(daNote.noteData) == spr.ID)
							{
								spr.animation.play('confirm', true);
							}
							if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
							{
								spr.centerOffsets();
								spr.offset.x -= 13;
								spr.offset.y -= 13;
							}
							else
								spr.centerOffsets();
						});
					}

					#if windows
					if (luaModchart != null)
						luaModchart.executeState('playerTwoSing', [Math.abs(daNote.noteData), Conductor.songPosition]);
					#end

					dad.holdTimer = 0;

					if (SONG.needsVoices)
						vocals.volume = 1;

					daNote.active = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}

				if (daNote.mustPress && !daNote.modifiedByLua)
				{
					daNote.visible = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].visible;
					daNote.x = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].x;
					if (!daNote.isSustainNote)
						daNote.modAngle = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].angle;
					if (daNote.sustainActive)
						daNote.alpha = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].alpha;
					daNote.modAngle = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].angle;
				}
				else if (!daNote.wasGoodHit && !daNote.modifiedByLua)
				{
					daNote.visible = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].visible;
					daNote.x = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].x;
					if (!daNote.isSustainNote)
						daNote.modAngle = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].angle;
					if (daNote.sustainActive)
						daNote.alpha = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].alpha;
					daNote.modAngle = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].angle;
				}

				if (daNote.isSustainNote)
				{
					daNote.x += daNote.width / 2 + 20;
					if (PlayState.curStage.startsWith('school'))
						daNote.x -= 11;
				}

				// trace(daNote.y);
				// WIP interpolation shit? Need to fix the pause issue
				// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));

				if ((daNote.mustPress && daNote.tooLate && !PlayStateChangeables.useDownscroll || daNote.mustPress && daNote.tooLate
					&& PlayStateChangeables.useDownscroll)
					&& daNote.mustPress)
				{
					if (daNote.isSustainNote && daNote.wasGoodHit)
						{
							daNote.kill();
							notes.remove(daNote, true);
						}
						else
						{
							if (loadRep && daNote.isSustainNote)
							{
								// im tired and lazy this sucks I know i'm dumb
								if (findByTime(daNote.strumTime) != null)
									totalNotesHit += 1;
								else
								{
									if (!daNote.isSustainNote)
										health -= 0.10;
									vocals.volume = 0;
									if (theFunne && !daNote.isSustainNote)
										noteMiss(daNote.noteData, daNote);
									if (daNote.isParent)
									{
										health -= 0.20; // give a health punishment for failing a LN
										trace("hold fell over at the start");
										for (i in daNote.children)
										{
											i.alpha = 0.3;
											i.sustainActive = false;
										}
									}
									else
									{
										if (!daNote.wasGoodHit
											&& daNote.isSustainNote
											&& daNote.sustainActive
											&& daNote.spotInLine != daNote.parent.children.length)
										{
											health -= 0.20; // give a health punishment for failing a LN
											trace("hold fell over at " + daNote.spotInLine);
											for (i in daNote.parent.children)
											{
												i.alpha = 0.3;
												i.sustainActive = false;
											}
											if (daNote.parent.wasGoodHit)
												misses++;
											updateAccuracy();
										}
									}
								}
							}
							else
							{
								if (!daNote.isSustainNote)
									health -= 0.10;
								vocals.volume = 0;
								if (theFunne && !daNote.isSustainNote)
									noteMiss(daNote.noteData, daNote);

								if (daNote.isParent)
								{
									health -= 0.20; // give a health punishment for failing a LN
									trace("hold fell over at the start");
									for (i in daNote.children)
									{
										i.alpha = 0.3;
										i.sustainActive = false;
										trace(i.alpha);
									}
								}
								else
								{
									if (!daNote.wasGoodHit
										&& daNote.isSustainNote
										&& daNote.sustainActive
										&& daNote.spotInLine != daNote.parent.children.length)
									{
										health -= 0.20; // give a health punishment for failing a LN
										trace("hold fell over at " + daNote.spotInLine);
										for (i in daNote.parent.children)
										{
											i.alpha = 0.3;
											i.sustainActive = false;
											trace(i.alpha);
										}
										if (daNote.parent.wasGoodHit)
											misses++;
										updateAccuracy();
									}
								}
							}
						}

						daNote.visible = false;
						daNote.kill();
						notes.remove(daNote, true);
					}
			});
		}

		if (FlxG.save.data.cpuStrums)
		{
			cpuStrums.forEach(function(spr:FlxSprite)
			{
				if (spr.animation.finished)
				{
					spr.animation.play('static');
					spr.centerOffsets();
				}
			});
		}

		if (!inCutscene && songStarted)
			keyShit();

		#if debug
		if (FlxG.keys.justPressed.ONE)
			endSabotage();
		if (FlxG.keys.justPressed.TWO)
			endMoogus();
		#end
	}

	function endSabotage():Void{
		camHUD.visible = false;
		inCutscene = true;
		startedCountdown = false;
		generatedMusic = false;
		canPause = false;
		camZooming = false;

		trace('we got past the initial stuff');
		
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;

		trace('change volume');

		camFollow.setPosition(gf.getGraphicMidpoint().x, dad.getGraphicMidpoint().y - 150);	
		dad.changeHoldState(true);
		boyfriend.changeHoldState(true);
		dad.playAnim('kill');
		boyfriend.playAnim('kill');
		FlxG.sound.play(Paths.sound('fire', 'impostor'));

		new FlxTimer().start(2.19, function(tmr:FlxTimer)
		{
				FlxTween.tween(FlxG.camera, {zoom: 0.95}, 0.5, {ease: FlxEase.circOut});
		});

		new FlxTimer().start(2.9, function(shot:FlxTimer)
		{
			FlxTween.tween(FlxG.camera, {zoom: 1}, 0.5, {ease: FlxEase.circOut});
		});

		new FlxTimer().start(5, function(trans:FlxTimer)
		{
			endSong();
		});
	}

	function endMoogus():Void{
		camHUD.visible = false;
		inCutscene = true;
		startedCountdown = false;
		generatedMusic = false;
		canPause = false;
		camZooming = false;

		trace('we got past the initial stuff');
		
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;

		trace('change volume');

		camFollow.setPosition(gf.getGraphicMidpoint().x, dad.getGraphicMidpoint().y - 150);	
		dad.changeHoldState(true);
		gf.changeHoldState(true);
		

		FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom - 0.1}, 1, {ease: FlxEase.quadOut});

		new FlxTimer().start(1, function(wait:FlxTimer)
		{
			dad.playAnim('gf');
			gf.playAnim('die');
			FlxG.sound.play(Paths.sound('meltdown_cutscene', 'impostor'));
		});

		new FlxTimer().start(5, function(trans:FlxTimer)
		{
			endSong();
		});
	}

	function endSong():Void
	{
		inCutscene = false;
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
		trace('pass event listeners');
		if (useVideo)
		{
			GlobalVideo.get().stop();
			FlxG.stage.window.onFocusOut.remove(focusOut);
			FlxG.stage.window.onFocusIn.remove(focusIn);
			PlayState.instance.remove(PlayState.instance.videoSprite);
			trace('video shit');
		}

		if (isStoryMode)
			campaignMisses = misses;

		trace('misses');

		if (!loadRep)
			rep.SaveReplay(saveNotes, saveJudge, replayAna);
		else
		{
			PlayStateChangeables.botPlay = false;
			PlayStateChangeables.scrollSpeed = 1;
			PlayStateChangeables.useDownscroll = false;
		}

		if (FlxG.save.data.fpsCap > 290)
			(cast(Lib.current.getChildAt(0), Main)).setFPSCap(290);

		#if windows
		if (luaModchart != null)
		{
			luaModchart.die();
			luaModchart = null;
		}
		#end

		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		FlxG.sound.music.pause();
		vocals.pause();
		trace('pause funny');
		if (SONG.validScore)
		{
			// adjusting the highscore song name to be compatible
			// would read original scores if we didn't change packages
			var songHighscore = StringTools.replace(PlayState.SONG.song, " ", "-");
			switch (songHighscore)
			{
				case 'Dad-Battle':
					songHighscore = 'Dadbattle';
				case 'Philly-Nice':
					songHighscore = 'Philly';
			}

			#if !switch
			Highscore.saveScore(songHighscore, Math.round(songScore), storyDifficulty);
			Highscore.saveCombo(songHighscore, Ratings.GenerateLetterRank(accuracy), storyDifficulty);
			#end
		}

		if (offsetTesting)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			offsetTesting = false;
			LoadingState.loadAndSwitchState(new OptionsMenu());
			FlxG.save.data.offset = offsetTest;
			trace('offset');
		}
		else
		{
			if (isStoryMode)
			{
				campaignScore += Math.round(songScore);

				storyPlaylist.remove(storyPlaylist[0]);

				if (storyPlaylist.length <= 0)
				{
					transIn = FlxTransitionableState.defaultTransIn;
					transOut = FlxTransitionableState.defaultTransOut;

					paused = true;

					FlxG.sound.music.stop();
					vocals.stop();
					if (FlxG.save.data.scoreScreen)
					{
						openSubState(new ResultsScreen());
						new FlxTimer().start(1, function(tmr:FlxTimer)
							{
								inResults = true;
							});
					}
					else
					{
						FlxG.sound.playMusic(Paths.music('freakyMenu'));
						Conductor.changeBPM(102);
						FlxG.switchState(new StoryMenuState());
					}

					#if windows
					if (luaModchart != null)
					{
						luaModchart.die();
						luaModchart = null;
					}
					#end

					if (SONG.validScore)
					{
						NGio.unlockMedal(60961);
						Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
					}

					StoryMenuState.unlockNextWeek(storyWeek);
				}
				else
				{
					// adjusting the song name to be compatible
					var songFormat = StringTools.replace(PlayState.storyPlaylist[0], " ", "-");
					switch (songFormat)
					{
						case 'Dad-Battle':
							songFormat = 'Dadbattle';
						case 'Philly-Nice':
							songFormat = 'Philly';
					}

					var poop:String = Highscore.formatSong(songFormat, storyDifficulty);

					trace('LOADING NEXT SONG');
					trace(poop);

					if (StringTools.replace(PlayState.storyPlaylist[0], " ", "-").toLowerCase() == 'eggnog')
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

					PlayState.SONG = Song.loadFromJson(poop, PlayState.storyPlaylist[0]);
					FlxG.sound.music.stop();

					LoadingState.loadAndSwitchState(new PlayState());
				}
			}
			else
			{
				trace('WENT BACK TO FREEPLAY??');

				paused = true;

				FlxG.sound.music.stop();
				vocals.stop();

				if (FlxG.save.data.scoreScreen) 
				{
					openSubState(new ResultsScreen());
					new FlxTimer().start(1, function(tmr:FlxTimer)
						{
							inResults = true;
						});
				}
				else
					FlxG.switchState(new FreeplayState());
			}
		}
	}

	var endingSong:Bool = false;

	var hits:Array<Float> = [];
	var offsetTest:Float = 0;

	var timeShown = 0;

	private function popUpScore(daNote:Note):Void
	{
		var noteDiff:Float = -(daNote.strumTime - Conductor.songPosition);
		var wife:Float = EtternaFunctions.wife3(-noteDiff, Conductor.timeScale);
		// boyfriend.playAnim('hey');
		vocals.volume = 1;
		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;
		coolText.y -= 350;
		coolText.cameras = [camHUD];
		//

		var rating:FlxSprite = new FlxSprite();
		var score:Float = 350;

		if (FlxG.save.data.accuracyMod == 1)
			totalNotesHit += wife;

		var daRating = daNote.rating;

		switch (daRating)
		{
			case 'shit':
				score = -300;
				combo = 0;
				misses++;
				health -= 0.06;
				ss = false;
				shits++;
				if (FlxG.save.data.accuracyMod == 0)
					totalNotesHit -= 1;
			case 'bad':
				daRating = 'bad';
				score = 0;
				health -= 0.03;
				ss = false;
				bads++;
				if (FlxG.save.data.accuracyMod == 0)
					totalNotesHit += 0.50;
			case 'good':
				daRating = 'good';
				score = 200;
				ss = false;
				goods++;
				if (FlxG.save.data.accuracyMod == 0)
					totalNotesHit += 0.75;
			case 'sick':
				if (health < 2)
					health += 0.04;
				if (FlxG.save.data.accuracyMod == 0)
					totalNotesHit += 1;
				sicks++;
		}


		// trace('Wife accuracy loss: ' + wife + ' | Rating: ' + daRating + ' | Score: ' + score + ' | Weight: ' + (1 - wife));

		if (daRating != 'shit' || daRating != 'bad')
		{
			songScore += Math.round(score);
			songScoreDef += Math.round(ConvertScore.convertScore(noteDiff));

			/* if (combo > 60)
					daRating = 'sick';
				else if (combo > 12)
					daRating = 'good'
				else if (combo > 4)
					daRating = 'bad';
			 */

			var pixelShitPart1:String = "";
			var pixelShitPart2:String = '';

			if (curStage.startsWith('school'))
			{
				pixelShitPart1 = 'weeb/pixelUI/';
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

			var msTiming = HelperFunctions.truncateFloat(noteDiff, 3);
			if (PlayStateChangeables.botPlay && !loadRep)
				msTiming = 0;

			if (loadRep)
				msTiming = HelperFunctions.truncateFloat(findByTime(daNote.strumTime)[3], 3);
			timeShown = 0;

			if (msTiming >= 0.03 && offsetTesting)
			{
				// Remove Outliers
				hits.shift();
				hits.shift();
				hits.shift();
				hits.pop();
				hits.pop();
				hits.pop();
				hits.push(msTiming);

				var total = 0.0;

				for (i in hits)
					total += i;

				offsetTest = HelperFunctions.truncateFloat(total / hits.length, 2);
			}


			var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
			comboSpr.screenCenter();
			comboSpr.x = rating.x;
			comboSpr.y = rating.y + 100;
			comboSpr.acceleration.y = 600;
			comboSpr.velocity.y -= 150;

			comboSpr.velocity.x += FlxG.random.int(1, 10);
			if (!PlayStateChangeables.botPlay || loadRep)
				add(rating);

			if (!curStage.startsWith('school'))
			{
				rating.setGraphicSize(Std.int(rating.width * 0.7));
				if(FlxG.save.data.antialiasing)
					{
						rating.antialiasing = true;
					}
				comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
				if(FlxG.save.data.antialiasing)
					{
						comboSpr.antialiasing = true;
					}
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

			if (combo > highestCombo)
				highestCombo = combo;

			// make sure we have 3 digits to display (looks weird otherwise lol)
			if (comboSplit.length == 1)
			{
				seperatedScore.push(0);
				seperatedScore.push(0);
			}
			else if (comboSplit.length == 2)
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

				if (!curStage.startsWith('school'))
				{
					if(FlxG.save.data.antialiasing)
						{
							numScore.antialiasing = true;
						}
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
			/* 
				trace(combo);
				trace(seperatedScore);
			 */

			coolText.text = Std.string(seperatedScore);
			// add(coolText);

			FlxTween.tween(rating, {alpha: 0}, 0.2, {
				startDelay: Conductor.crochet * 0.001,
				onUpdate: function(tween:FlxTween)
				{
					timeShown++;
				}
			});

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

	var upHold:Bool = false;
	var downHold:Bool = false;
	var rightHold:Bool = false;
	var leftHold:Bool = false;

	// THIS FUNCTION JUST FUCKS WIT HELD NOTES AND BOTPLAY/REPLAY (also gamepad shit)

	private function keyShit():Void // I've invested in emma stocks
	{
		// control arrays, order L D R U
		var holdArray:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
		var pressArray:Array<Bool> = [controls.LEFT_P, controls.DOWN_P, controls.UP_P, controls.RIGHT_P];
		var releaseArray:Array<Bool> = [controls.LEFT_R, controls.DOWN_R, controls.UP_R, controls.RIGHT_R];
		#if windows
		if (luaModchart != null)
		{
			if (controls.LEFT_P)
			{
				luaModchart.executeState('keyPressed', ["left"]);
			};
			if (controls.DOWN_P)
			{
				luaModchart.executeState('keyPressed', ["down"]);
			};
			if (controls.UP_P)
			{
				luaModchart.executeState('keyPressed', ["up"]);
			};
			if (controls.RIGHT_P)
			{
				luaModchart.executeState('keyPressed', ["right"]);
			};
		};
		#end

		// Prevent player input if botplay is on
		if (PlayStateChangeables.botPlay)
		{
			holdArray = [false, false, false, false];
			pressArray = [false, false, false, false];
			releaseArray = [false, false, false, false];
		}

		var anas:Array<Ana> = [null, null, null, null];

		for (i in 0...pressArray.length)
			if (pressArray[i])
				anas[i] = new Ana(Conductor.songPosition, null, false, "miss", i);

		// HOLDS, check for sustain notes
		if (holdArray.contains(true) && /*!boyfriend.stunned && */ generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && holdArray[daNote.noteData] && daNote.sustainActive)
				{
					trace(daNote.sustainActive);
					goodNoteHit(daNote);
				}
			});
		}

		if ((KeyBinds.gamepad && !FlxG.keys.justPressed.ANY))
		{
			// PRESSES, check for note hits
			if (pressArray.contains(true) && generatedMusic)
			{
				boyfriend.holdTimer = 0;

				var possibleNotes:Array<Note> = []; // notes that can be hit
				var directionList:Array<Int> = []; // directions that can be hit
				var dumbNotes:Array<Note> = []; // notes to kill later
				var directionsAccounted:Array<Bool> = [false, false, false, false]; // we don't want to do judgments for more than one presses

				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !directionsAccounted[daNote.noteData])
					{
						if (directionList.contains(daNote.noteData))
						{
							directionsAccounted[daNote.noteData] = true;
							for (coolNote in possibleNotes)
							{
								if (coolNote.noteData == daNote.noteData && Math.abs(daNote.strumTime - coolNote.strumTime) < 10)
								{ // if it's the same note twice at < 10ms distance, just delete it
									// EXCEPT u cant delete it in this loop cuz it fucks with the collection lol
									dumbNotes.push(daNote);
									break;
								}
								else if (coolNote.noteData == daNote.noteData && daNote.strumTime < coolNote.strumTime)
								{ // if daNote is earlier than existing note (coolNote), replace
									possibleNotes.remove(coolNote);
									possibleNotes.push(daNote);
									break;
								}
							}
						}
						else
						{
							directionsAccounted[daNote.noteData] = true;
							possibleNotes.push(daNote);
							directionList.push(daNote.noteData);
						}
					}
				});

				for (note in dumbNotes)
				{
					FlxG.log.add("killing dumb ass note at " + note.strumTime);
					note.kill();
					notes.remove(note, true);
					note.destroy();
				}

				possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

				var hit = [false,false,false,false];

				if (perfectMode)
					goodNoteHit(possibleNotes[0]);
				else if (possibleNotes.length > 0)
				{
					if (!FlxG.save.data.ghost)
					{
						for (shit in 0...pressArray.length)
						{ // if a direction is hit that shouldn't be
							if (pressArray[shit] && !directionList.contains(shit))
								noteMiss(shit, null);
						}
					}
					for (coolNote in possibleNotes)
					{
						if (pressArray[coolNote.noteData] && !hit[coolNote.noteData])
						{
							if (mashViolations != 0)
								mashViolations--;
							hit[coolNote.noteData] = true;
							scoreTxt.color = FlxColor.WHITE;
							var noteDiff:Float = -(coolNote.strumTime - Conductor.songPosition);
							anas[coolNote.noteData].hit = true;
							anas[coolNote.noteData].hitJudge = Ratings.CalculateRating(noteDiff, Math.floor((PlayStateChangeables.safeFrames / 60) * 1000));
							anas[coolNote.noteData].nearestNote = [coolNote.strumTime, coolNote.noteData, coolNote.sustainLength];
							goodNoteHit(coolNote);
						}
					}
				};
				
				if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && (!holdArray.contains(true) || PlayStateChangeables.botPlay))
				{
					if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss') && boyfriend.animation.curAnim.curFrame >= 10)
						if(!boyfriend.holdState && !inCutscene) {
							boyfriend.playAnim('idle');
						}
				}
				else if (!FlxG.save.data.ghost)
				{
					for (shit in 0...pressArray.length)
						if (pressArray[shit])
							noteMiss(shit, null);
				}
			}

			if (!loadRep)
				for (i in anas)
					if (i != null)
						replayAna.anaArray.push(i); // put em all there
		}
		notes.forEachAlive(function(daNote:Note)
		{
			if (PlayStateChangeables.useDownscroll && daNote.y > strumLine.y || !PlayStateChangeables.useDownscroll && daNote.y < strumLine.y)
			{
				// Force good note hit regardless if it's too late to hit it or not as a fail safe
				if (PlayStateChangeables.botPlay && daNote.canBeHit && daNote.mustPress || PlayStateChangeables.botPlay && daNote.tooLate && daNote.mustPress)
				{
					if (loadRep)
					{
						// trace('ReplayNote ' + tmpRepNote.strumtime + ' | ' + tmpRepNote.direction);
						var n = findByTime(daNote.strumTime);
						trace(n);
						if (n != null)
						{
							goodNoteHit(daNote);
							boyfriend.holdTimer = daNote.sustainLength;
						}
					}
					else
					{
						goodNoteHit(daNote);
						boyfriend.holdTimer = daNote.sustainLength;
					}
				}
			}
		});

		if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && (!holdArray.contains(true) || PlayStateChangeables.botPlay))
		{
			if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss') && boyfriend.animation.curAnim.curFrame >= 10)
				if(!boyfriend.holdState && !inCutscene) {
					boyfriend.playAnim('idle');
				}
		}

		playerStrums.forEach(function(spr:FlxSprite)
		{
			if (keys[spr.ID] && spr.animation.curAnim.name != 'confirm')
				spr.animation.play('pressed');
			if (!keys[spr.ID])
				spr.animation.play('static');

			if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
			{
				spr.centerOffsets();
				spr.offset.x -= 13;
				spr.offset.y -= 13;
			}
			else
				spr.centerOffsets();
		});
	}

	public function findByTime(time:Float):Array<Dynamic>
	{
		for (i in rep.replay.songNotes)
		{
			// trace('checking ' + Math.round(i[0]) + ' against ' + Math.round(time));
			if (i[0] == time)
				return i;
		}
		return null;
	}

	public function findByTimeIndex(time:Float):Int
	{
		for (i in 0...rep.replay.songNotes.length)
		{
			// trace('checking ' + Math.round(i[0]) + ' against ' + Math.round(time));
			if (rep.replay.songNotes[i][0] == time)
				return i;
		}
		return -1;
	}

	public var fuckingVolume:Float = 1;
	public var useVideo = false;

	public static var webmHandler:WebmHandler;

	public var playingDathing = false;

	public var videoSprite:FlxSprite;

	public function focusOut()
	{
		if (paused)
			return;
		persistentUpdate = false;
		persistentDraw = true;
		paused = true;

		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.pause();
			vocals.pause();
		}

		openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
	}

	public function focusIn()
	{
		// nada
	}

	public function backgroundVideo(source:String) // for background videos
	{
		#if cpp
		useVideo = true;

		FlxG.stage.window.onFocusOut.add(focusOut);
		FlxG.stage.window.onFocusIn.add(focusIn);

		var ourSource:String = "assets/videos/daWeirdVid/dontDelete.webm";
		//WebmPlayer.SKIP_STEP_LIMIT = 90;
		var str1:String = "WEBM SHIT";
		webmHandler = new WebmHandler();
		webmHandler.source(ourSource);
		webmHandler.makePlayer();
		webmHandler.webm.name = str1;

		GlobalVideo.setWebm(webmHandler);

		GlobalVideo.get().source(source);
		GlobalVideo.get().clearPause();
		if (GlobalVideo.isWebm)
		{
			GlobalVideo.get().updatePlayer();
		}
		GlobalVideo.get().show();

		if (GlobalVideo.isWebm)
		{
			GlobalVideo.get().restart();
		}
		else
		{
			GlobalVideo.get().play();
		}

		var data = webmHandler.webm.bitmapData;

		videoSprite = new FlxSprite(-470, -30).loadGraphic(data);

		videoSprite.setGraphicSize(Std.int(videoSprite.width * 1.2));

		remove(gf);
		remove(boyfriend);
		remove(dad);
		add(videoSprite);
		add(gf);
		add(boyfriend);
		add(dad);

		trace('poggers');

		if (!songStarted)
			webmHandler.pause();
		else
			webmHandler.resume();
		#end
	}

	function noteMiss(direction:Int = 1, daNote:Note):Void
	{
		if (!boyfriend.stunned)
		{
			//health -= 0.2;
			if (combo > 5 && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			combo = 0;
			misses++;

			if (daNote != null)
			{
				if (!loadRep)
				{
					saveNotes.push([
						daNote.strumTime,
						0,
						direction,
						166 * Math.floor((PlayState.rep.replay.sf / 60) * 1000) / 166
					]);
					saveJudge.push("miss");
				}
			}
			else if (!loadRep)
			{
				saveNotes.push([
					Conductor.songPosition,
					0,
					direction,
					166 * Math.floor((PlayState.rep.replay.sf / 60) * 1000) / 166
				]);
				saveJudge.push("miss");
			}

			// var noteDiff:Float = Math.abs(daNote.strumTime - Conductor.songPosition);
			// var wife:Float = EtternaFunctions.wife3(noteDiff, FlxG.save.data.etternaMode ? 1 : 1.7);

			if (FlxG.save.data.accuracyMod == 1)
				totalNotesHit -= 1;

			if (daNote != null)
			{
				if (!daNote.isSustainNote)
					songScore -= 10;
			}
			else
				songScore -= 10;
			
			if(FlxG.save.data.missSounds)
				{
					FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
					// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
					// FlxG.log.add('played imss note');
				}

			// Hole switch statement replaced with a single line :)
			boyfriend.playAnim('sing' + dataSuffix[direction] + 'miss', true);

			#if windows
			if (luaModchart != null)
				luaModchart.executeState('playerOneMiss', [direction, Conductor.songPosition]);
			#end

			updateAccuracy();
		}
	}

	/*function badNoteCheck()
			{
				// just double pasting this shit cuz fuk u
				// REDO THIS SYSTEM!
				var upP = controls.UP_P;
				var rightP = controls.RIGHT_P;
				var downP = controls.DOWN_P;
				var leftP = controls.LEFT_P;

				if (leftP)
					noteMiss(0);
				if (upP)
					noteMiss(2);
				if (rightP)
					noteMiss(3);
				if (downP)
					noteMiss(1);
				updateAccuracy();
			}
	 */
	function updateAccuracy()
	{
		totalPlayed += 1;
		accuracy = Math.max(0, totalNotesHit / totalPlayed * 100);
		accuracyDefault = Math.max(0, totalNotesHitDefault / totalPlayed * 100);
	}

	function getKeyPresses(note:Note):Int
	{
		var possibleNotes:Array<Note> = []; // copypasted but you already know that

		notes.forEachAlive(function(daNote:Note)
		{
			if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate)
			{
				possibleNotes.push(daNote);
				possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
			}
		});
		if (possibleNotes.length == 1)
			return possibleNotes.length + 1;
		return possibleNotes.length;
	}

	var mashing:Int = 0;
	var mashViolations:Int = 0;

	var etternaModeScore:Int = 0;

	function noteCheck(controlArray:Array<Bool>, note:Note):Void // sorry lol
	{
		var noteDiff:Float = -(note.strumTime - Conductor.songPosition);

		note.rating = Ratings.CalculateRating(noteDiff, Math.floor((PlayStateChangeables.safeFrames / 60) * 1000));

		/* if (loadRep)
			{
				if (controlArray[note.noteData])
					goodNoteHit(note, false);
				else if (rep.replay.keyPresses.length > repPresses && !controlArray[note.noteData])
				{
					if (NearlyEquals(note.strumTime,rep.replay.keyPresses[repPresses].time, 4))
					{
						goodNoteHit(note, false);
					}
				}
		}*/

		if (controlArray[note.noteData])
		{
			goodNoteHit(note, (mashing > getKeyPresses(note)));

			/*if (mashing > getKeyPresses(note) && mashViolations <= 2)
				{
					mashViolations++;

					goodNoteHit(note, (mashing > getKeyPresses(note)));
				}
				else if (mashViolations > 2)
				{
					// this is bad but fuck you
					playerStrums.members[0].animation.play('static');
					playerStrums.members[1].animation.play('static');
					playerStrums.members[2].animation.play('static');
					playerStrums.members[3].animation.play('static');
					health -= 0.4;
					trace('mash ' + mashing);
					if (mashing != 0)
						mashing = 0;
				}
				else
					goodNoteHit(note, false); */
		}
	}

	function goodNoteHit(note:Note, resetMashViolation = true):Void
	{
		if (mashing != 0)
			mashing = 0;

		var noteDiff:Float = -(note.strumTime - Conductor.songPosition);

		if (loadRep)
		{
			noteDiff = findByTime(note.strumTime)[3];
			note.rating = rep.replay.songJudgements[findByTimeIndex(note.strumTime)];
		}
		else
			note.rating = Ratings.CalculateRating(noteDiff);

		if (note.rating == "miss")
			return;

		// add newest note to front of notesHitArray
		// the oldest notes are at the end and are removed first
		if (!note.isSustainNote)
			notesHitArray.unshift(Date.now());

		if (!resetMashViolation && mashViolations >= 1)
			mashViolations--;

		if (mashViolations < 0)
			mashViolations = 0;

		if (!note.wasGoodHit)
		{
			if (!note.isSustainNote)
			{
				popUpScore(note);
				combo += 1;
			}
			else
				totalNotesHit += 1;

			switch (note.noteData)
			{
				case 2:
					boyfriend.playAnim('singUP', true);
				case 3:
					boyfriend.playAnim('singRIGHT', true);
				case 1:
					boyfriend.playAnim('singDOWN', true);
				case 0:
					boyfriend.playAnim('singLEFT', true);
			}

			#if windows
			if (luaModchart != null)
				luaModchart.executeState('playerOneSing', [note.noteData, Conductor.songPosition]);
			#end

			if (!loadRep && note.mustPress)
			{
				var array = [note.strumTime, note.sustainLength, note.noteData, noteDiff];
				if (note.isSustainNote)
					array[1] = -1;
				saveNotes.push(array);
				saveJudge.push(note.rating);
			}

			playerStrums.forEach(function(spr:FlxSprite)
			{
				if (Math.abs(note.noteData) == spr.ID)
				{
					spr.animation.play('confirm', true);
				}
			});

			note.kill();
			notes.remove(note, true);
			note.destroy();

			updateAccuracy();
		}
	}

	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		if (FlxG.save.data.distractions)
		{
			fastCar.x = -12600;
			fastCar.y = FlxG.random.int(140, 250);
			fastCar.velocity.x = 0;
			fastCarCanDrive = true;
		}
	}

	function fastCarDrive()
	{
		if (FlxG.save.data.distractions)
		{
			FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

			fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
			fastCarCanDrive = false;
			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				resetFastCar();
			});
		}
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void
	{
		if (FlxG.save.data.distractions)
		{
			trainMoving = true;
			if (!trainSound.playing)
				trainSound.play(true);
		}
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (FlxG.save.data.distractions)
		{
			if (trainSound.time >= 4700)
			{
				startedMoving = true;
				gf.playAnim('hairBlow');
			}

			if (startedMoving)
			{
				phillyTrain.x -= 400;

				if (phillyTrain.x < -2000 && !trainFinishing)
				{
					phillyTrain.x = -1150;
					trainCars -= 1;

					if (trainCars <= 0)
						trainFinishing = true;
				}

				if (phillyTrain.x < -4000 && trainFinishing)
					trainReset();
			}
		}
	}

	function trainReset():Void
	{
		if (FlxG.save.data.distractions)
		{
			gf.playAnim('hairFall');
			phillyTrain.x = FlxG.width + 200;
			trainMoving = false;
			// trainSound.stop();
			// trainSound.time = 0;
			trainCars = 8;
			trainFinishing = false;
			startedMoving = false;
		}
	}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
		halloweenBG.animation.play('lightning');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		boyfriend.playAnim('scared', true);
		gf.playAnim('scared', true);
	}
	
	function bgFlash():Void
		{
			//oops im stupid so commented out the tweening version
			//flashSprite.alpha = 0;
			//FlxTween.tween(flashSprite.alpha, 0.4, 0.15);
			trace('BG FLASH FUNNY');
			//yeaaah nice try buckaroo cant FLASH WHILE IN A CUTSCENE!! BITCH!!!!!!!!
			if(!inCutscene)
				flashSprite.alpha = 0.4;
		}
	var danced:Bool = false;

	override function stepHit()
	{
		super.stepHit();
		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
		{
			resyncVocals();
		}

		flashSprite.alpha -= 0.08;

		#if windows
		if (executeModchart && luaModchart != null)
		{
			luaModchart.setVar('curStep', curStep);
			luaModchart.executeState('stepHit', [curStep]);
		}
		#end

		// yes this updates every step.
		// yes this is bad
		// but i'm doing it to update misses and accuracy
		#if windows
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
			+ HelperFunctions.truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC, true,
			songLength
			- Conductor.songPosition);
		#end
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	override function beatHit()
	{
		super.beatHit();

		var lightsDownTrue = [64, 160, 272, 280, 288, 296, 298, 300, 302, 304, 368];
		var lightsDownFalse = [128, 192, 276, 284, 292, 297, 299, 301, 303, 360, 400];
		if(curSong == "Lights-Down" && curBeat == 1) 
		{
			changeDadCharacter("whiteimpostor");
			changeBFCharacter("bfeyes");
			changeDadCharacter("impostor3");
			changeBFCharacter("bf");			
		}
		if(curSong == "Lights-Down" && curBeat == 32) 
		{
			PartialLightsOUT(true);
		}
		if(curSong == "Lights-Down")
		{
			for (i in 0...lightsDownTrue.length)
			{
				if (curBeat == lightsDownTrue[i])
					LightsOUT(true);
			}
			for (i in 0...lightsDownFalse.length)
			{
				if (curBeat == lightsDownFalse[i])
					LightsOUT(false);
			}

		}

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, (PlayStateChangeables.useDownscroll ? FlxSort.ASCENDING : FlxSort.DESCENDING));
		}

		#if windows
		if (executeModchart && luaModchart != null)
		{
			luaModchart.executeState('beatHit', [curBeat]);
		}
		#end

		if(FlxG.save.data.distractions)
			{var sussusBeats = [94, 95, 288, 296, 304, 312, 318, 319];
				var saboBeats = [16, 24, 32, 40, 48, 56, 62, 63, 272, 280, 288, 296, 302, 303, 376, 384, 892];
				var meltBeats = [0, 16, 32, 48, 64, 72, 80, 88, 96, 104, 112, 120, 126, 127, 200, 208, 216, 224, 232, 240, 248, 256, 272, 288, 304, 320, 336, 352, 368, 382, 464, 480, 496, 512];
				var toogusBeats = [94, 95, 96, 98, 100, 102, 104, 106, 107, 109, 112, 114, 116, 118, 120, 122, 124, 126, 128, 130, 132, 134, 136, 138, 140, 142, 144, 146, 148, 150, 152, 154, 156, 158, 192, 194, 196, 198, 200, 202, 204, 206, 208, 210, 212, 214, 216, 218, 220, 222, 288, 296, 304, 312, 318, 319, 320, 322, 324, 326, 328, 330, 332, 334, 336, 338, 340, 342, 344, 346, 348, 350, 352, 354, 356, 358, 360, 362, 364, 366, 368, 370, 372, 374, 376, 378, 380, 382];
				var reactorBeats = [1, 16, 32, 48, 64, 72, 80, 88, 96, 104, 112, 120, 126, 127, 128, 132, 136, 140, 144, 148, 152, 156, 160, 164, 168, 172, 176, 180, 184, 188, 448, 456, 464, 472, 476, 478, 480, 484, 488, 492, 496, 500, 504, 508, 512, 516, 520, 524, 528, 532, 536, 540, 544, 548, 552, 556, 560, 564, 568, 572, 576, 580, 584, 588, 592, 596, 600, 604];
				var _b = 0;
				//FlxG.watch.addQuick("Flash Timer", _cb); debug stuff
		
				add(flashSprite);
				flashSprite.alpha = 0;
				flashSprite.scrollFactor.set(0, 0);
		
				if(curSong == 'Sussus-Moogus') // sussus flashes
				{
					
					if(curBeat == 97 || curBeat == 192 || curBeat == 320)
						_cb = 1;
						if(curBeat > 98 && curBeat < 160 || curBeat > 192 && curBeat < 224 || curBeat > 320 && curBeat < 382 || curBeat == 98 || curBeat == 160 || curBeat == 192 || curBeat == 224 || curBeat == 320 || curBeat == 382)
						{
							_cb++;
							if(_cb == 2)
							{
								bgFlash();
								_cb = 0;
							}
						}
					while(_b < sussusBeats.length) {
					var susflash = sussusBeats[_b];
						++_b;
						if(curBeat == susflash)
						{
							bgFlash();
						}
					}
				}
				if(curSong == 'Sabotage') // sabotage flashes
				{
					while(_b < saboBeats.length) {
						var sabflash = saboBeats[_b];
							++_b;
							if(curBeat == sabflash)
							{
								bgFlash();
							}
						}
		
						if(curBeat == 63 || curBeat == 304)
							_cb = 3;
						if(curBeat > 64 && curBeat < 124 || curBeat > 304 && curBeat < 370 || curBeat == 64 || curBeat == 124 || curBeat == 304 || curBeat == 370)
						{
							_cb++;
							if(_cb == 4)
							{
								bgFlash();
								_cb = 0;
							}
						}
				}
				if(curSong == 'Meltdown') // meltdown flashes
				{
					while(_b < meltBeats.length) {
						var meltflash = meltBeats[_b];
						++_b;
						if(curBeat == meltflash)
						{
							bgFlash();
						}
					}
					if(curBeat == 127)
						_cb = 3;
					if(curBeat == 382)
						_cb = 1;
					if(curBeat > 128 && curBeat < 192 || curBeat > 382 && curBeat < 448 || curBeat == 128 || curBeat == 192 || curBeat == 382 || curBeat == 448)
					{
						_cb++;
						if(_cb == 4)
						{
							bgFlash();
							_cb = 0;
						}
					}
				}
				if(curSong == 'Sussus-Toogus') // toogus flashes
				{
					while(_b < toogusBeats.length) {
						var meltflash = toogusBeats[_b];
						++_b;
						if(curBeat == meltflash)
						{
							bgFlash();
						}
					}
				}
			
				if(curSong == 'Reactor') // reactor flashes
				{
					while(_b < reactorBeats.length) {
						var meltflash = reactorBeats[_b];
						++_b;
						if(curBeat == meltflash)
						{
							bgFlash();
						}
					}
				}
			}
	

		if (curSong == 'Tutorial' && dad.curCharacter == 'gf')
		{
			if (SONG.notes[Math.floor(curStep / 16)].mustHitSection)
				dad.dance();
			else
			{
				if (curBeat == 73 || curBeat % 4 == 0 || curBeat % 4 == 1)
					dad.playAnim('danceLeft', true);
				else
					dad.playAnim('danceRight', true);
			}
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			// else
			// Conductor.changeBPM(SONG.bpm);

			// Dad doesnt interupt his own notes
			if ((SONG.notes[Math.floor(curStep / 16)].mustHitSection || !dad.animation.curAnim.name.startsWith("sing")) && dad.curCharacter != 'gf')
				if ((curBeat % idleBeat == 0 || !idleToBeat) || dad.curCharacter == "spooky")
					dad.dance(idleToBeat);
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);
		wiggleShit.update(Conductor.crochet);

		if (FlxG.save.data.camzoom)
		{
			// HARDCODING FOR MILF ZOOMS!
			if (curSong.toLowerCase() == 'milf' && curBeat >= 168 && curBeat < 200 && camZooming && FlxG.camera.zoom < 1.35)
			{
				FlxG.camera.zoom += 0.015;
				camHUD.zoom += 0.03;
			}

			if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
			{
				FlxG.camera.zoom += 0.015;
				camHUD.zoom += 0.03;
			}

			//drop 1
			if (curSong.toLowerCase() == 'reactor' && curBeat >= 128 && curBeat < 191 && camZooming && FlxG.camera.zoom < 1.35)
			{
				FlxG.camera.zoom += 0.025;
				camHUD.zoom += 0.03;
			}
			//drop 2
			if (curSong.toLowerCase() == 'reactor' && curBeat >= 319 && curBeat < 383 && camZooming && FlxG.camera.zoom < 1.35)
			{
				FlxG.camera.zoom += 0.025;
				camHUD.zoom += 0.03;
			}
			
			if (curSong.toLowerCase() == 'reactor' && curBeat >= 480 && curBeat < 607 && camZooming && FlxG.camera.zoom < 1.35)
			{
				FlxG.camera.zoom += 0.035;
				camHUD.zoom += 0.03;
			}
		}

		iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		iconP2.setGraphicSize(Std.int(iconP2.width + 30));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (curBeat % gfSpeed == 0)
		{
			gf.dance();
		}

		if (!boyfriend.animation.curAnim.name.startsWith("sing") && (curBeat % idleBeat == 0 || !idleToBeat))
		{
			if(!boyfriend.holdState && !inCutscene) {
				boyfriend.playAnim('idle', idleToBeat);
			}
		}

		if (curBeat == 260 && curSong == 'Rivals')
		{
			boyfriend.playAnim('shoot', true);
		}

		if (curBeat == 260 && curSong == 'Rivals')
		{
			dad.playAnim('die', true);
		}


		/*if (!dad.animation.curAnim.name.startsWith("sing"))
		{
			dad.dance();
		}*/

		if (curBeat % 8 == 7 && curSong == 'Bopeebo')
		{
			boyfriend.playAnim('hey', true);
		}

		if (curBeat % 4 == 0 && curSong == 'Reactor')
		{
			orb.scale.set(0.75, 0.75);
			ass2.alpha = 0.9;
			orb.alpha = 1;
		}
	//drop 1
		if (curBeat == 128 && curSong == 'Reactor')
    {
			defaultCamZoom = 0.7;
			camFollow.setPosition(gf.getGraphicMidpoint().x, gf.getGraphicMidpoint().y + 100);
    }

		if (curBeat == 191 && curSong == 'Reactor')
    {
			defaultCamZoom = 0.5;
			camFollow.setPosition(gf.getGraphicMidpoint().x, gf.getGraphicMidpoint().y - 100);
    }
	//drop 2
		if (curBeat == 319 && curSong == 'Reactor')
    {
			defaultCamZoom = 0.7;
			camFollow.setPosition(gf.getGraphicMidpoint().x, gf.getGraphicMidpoint().y + 100);
    }

		if (curBeat == 383 && curSong == 'Reactor')
    {
			defaultCamZoom = 0.5;
			camFollow.setPosition(gf.getGraphicMidpoint().x, gf.getGraphicMidpoint().y - 100);
    }
	//FUCKING EPIC DROP NIGGA!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	//clowfoe wrote this btw im not racist
		if (curBeat == 480 && curSong == 'Reactor')
    {
			defaultCamZoom = 0.9;
			camFollow.setPosition(gf.getGraphicMidpoint().x, gf.getGraphicMidpoint().y + 100);
    }

		if (curBeat == 607 && curSong == 'Reactor')
    {
			defaultCamZoom = 0.7;
			camFollow.setPosition(gf.getGraphicMidpoint().x, gf.getGraphicMidpoint().y + 100);
    }

		if (curBeat % 16 == 15 && SONG.song == 'Tutorial' && dad.curCharacter == 'gf' && curBeat > 16 && curBeat < 48)
		{
			boyfriend.playAnim('hey', true);
			dad.playAnim('cheer', true);
		}

		switch (curStage)
		{
			case 'school':
				if (FlxG.save.data.distractions)
				{
					bgGirls.dance();
				}

			case 'mall':
				if (FlxG.save.data.distractions)
				{
					upperBoppers.animation.play('bop', true);
					bottomBoppers.animation.play('bop', true);
					santa.animation.play('idle', true);
				}
			case 'reactor':
				if(curBeat % 4 == 0) {
					amogus.animation.play('bop', true);
					dripster.animation.play('bop', true);
					yellow.animation.play('bop', true);
					brown.animation.play('bop', true);
				}

			case 'meltdown':
				if(curBeat % 4 == 0) {
					crowd.animation.play('CrowdBop', true);
				}

			case 'limo':
				if (FlxG.save.data.distractions)
				{
					grpLimoDancers.forEach(function(dancer:BackgroundDancer)
					{
						dancer.dance();
					});

					if (FlxG.random.bool(10) && fastCarCanDrive)
						fastCarDrive();
				}
			case "philly":
				if (FlxG.save.data.distractions)
				{
					if (!trainMoving)
						trainCooldown += 1;

					if (curBeat % 4 == 0)
					{
						phillyCityLights.forEach(function(light:FlxSprite)
						{
							light.visible = false;
						});

						curLight = FlxG.random.int(0, phillyCityLights.length - 1);

						phillyCityLights.members[curLight].visible = true;
						// phillyCityLights.members[curLight].alpha = 1;
					}
				}

				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
				{
					if (FlxG.save.data.distractions)
					{
						trainCooldown = FlxG.random.int(-4, 0);
						trainStart();
					}
				}
		}

		if (isHalloween && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			if (FlxG.save.data.distractions)
			{
				lightningStrikeShit();
			}
		}
	}

	function PartialLightsOUT(id:Bool)
	{
		if(id)
		{
			camGame.flash(FlxColor.BLACK, 1);
			machineDark.alpha = 1;
			bgDark.alpha = 1;
			stageFront2Dark.alpha = 1;
			stageFront3Dark.alpha = 1;
			miraGradient.alpha = 1;
		}else{
			camGame.flash(FlxColor.WHITE, 0.35);
			machineDark.alpha = 0;
			bgDark.alpha = 0;
			stageFront2Dark.alpha = 0;
			stageFront3Dark.alpha = 0;
			miraGradient.alpha = 0;
		}

	}

	function LightsOUT(id:Bool)
	{
		if(id)
		{
			camGame.flash(FlxColor.WHITE, 0.35);
			lightsOutSprite.alpha = 1;
			gf.alpha = 0;
			stageFront2.alpha = 0;
			stageFront3.alpha = 0;
			changeDadCharacter("whiteimpostor");
			changeBFCharacter("bfeyes");
			healthBar.createFilledBar(FlxColor.fromString('#FF' + dad.playerColor), FlxColor.fromString('#FF' + boyfriend.playerColor));
			miraGradient.alpha = 0;
			stageFront2Dark.alpha = 0;
			stageFront3Dark.alpha = 0;
			
		}else{
			camGame.flash(FlxColor.BLACK, 0.35);
			lightsOutSprite.alpha = 0;
			gf.alpha = 1;
			stageFront2.alpha = 1;
			stageFront3.alpha = 1;
			changeDadCharacter("impostor3");
			changeBFCharacter("bf");
			healthBar.createFilledBar(FlxColor.fromString('#FF' + dad.playerColor), FlxColor.fromString('#FF' + boyfriend.playerColor));
			miraGradient.alpha = 1;
			stageFront2Dark.alpha = 1;
			stageFront2Dark.alpha = 1;
		}
		
	}

	function changeDadCharacter(id:String) // thth an kj you bob mod you are epic!!!!1!! - fabs
	{				
		var olddadx = dad.x;
		var olddady = dad.y;
		remove(dad);
		dad = new Character(olddadx, olddady, id);
		add(dad);
		iconP2.changeIcon(id);
	}

	function changeBFCharacter(id:String) // thth an kj you bob mod you are epic!!!!1!! - fabs
	{				
		var oldboyfriendx = boyfriend.x;
		var oldboyfriendy = boyfriend.y;
		remove(boyfriend);
		boyfriend = new Boyfriend(oldboyfriendx, oldboyfriendy, id);
		add(boyfriend);
		iconP1.changeIcon(id);
	}

	var curLight:Int = 0;
}
