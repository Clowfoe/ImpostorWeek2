package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class GameOverSubstate extends MusicBeatSubstate
{
	var bf:Boyfriend;
	var camFollow:FlxObject;

	var inSecret:Bool = false;

	var stageSuffix:String = "";

	public function new(x:Float, y:Float)
	{
		var daStage = PlayState.curStage;
		var daBf:String = '';
		switch (PlayState.SONG.player1)
		{
			case 'bf-pixel':
				stageSuffix = '-pixel';
				daBf = 'bf-pixel-dead';
			case 'bf-sus':
				stageSuffix = '-pixel';
				daBf = 'bf-pixel-dead';
			case 'bf-fall':
				daBf = 'bf-fall';
			default:
				daBf = 'bf';
		}

		switch (PlayState.SONG.player2)
		{
			case 'black':
			{
				if(FlxG.random.bool(5))	
				{
					daBf = 'bf-defeat-secret';
					inSecret = true;
				}
				else
					daBf = 'bf-defeat-death';
			}
		}

		super();

		Conductor.songPosition = 0;

		if(PlayState.SONG.player2 == 'black')
		{
			var defeatBG:FlxSprite = new FlxSprite(-70, -70).makeGraphic(5000, 5000, 0xFF1a182e);
			defeatBG.screenCenter();
			add(defeatBG);
		}

		bf = new Boyfriend(x, y, daBf);
		add(bf);

		camFollow = new FlxObject(bf.getGraphicMidpoint().x, bf.getGraphicMidpoint().y - 100, 1, 1);
		if(inSecret)
			camFollow = new FlxObject(bf.getGraphicMidpoint().x, bf.getGraphicMidpoint().y, 1, 1);
		add(camFollow);

		if(PlayState.SONG.player2 == 'black')
		{
			if(!inSecret)
				FlxG.sound.play(Paths.sound('loss-defeat', 'impostor'));
			else
				FlxG.sound.play(Paths.sound('no-balls', 'impostor'));
		}
		else if(PlayState.SONG.player2 == 'bf-fall') {
			FlxG.sound.play(Paths.sound('loss_ejected', 'impostor'));
		}
		else{
			FlxG.sound.play(Paths.sound('fnf_loss_sfx'));
		}
		Conductor.changeBPM(100);

		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		bf.playAnim('firstDeath');
	}

	var startVibin:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.ACCEPT)
		{
			if(bf.animation.curAnim.name != 'firstDeath' && inSecret)
				endBullshit();
			if(!inSecret)
				endBullshit();
		}

		if (controls.BACK)
		{
			FlxG.sound.music.stop();

			if (PlayState.isStoryMode)
				FlxG.switchState(new StoryMenuState());
			else
				FlxG.switchState(new FreeplayState());
			PlayState.loadRep = false;
		}

		if(PlayState.SONG.player2 == 'black')
		{
			FlxG.camera.follow(camFollow, LOCKON);
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.curFrame == 12 && PlayState.SONG.player2 != 'black')
		{
			FlxG.camera.follow(camFollow, LOCKON, 0.01);
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.finished)
		{
			if(PlayState.SONG.player2 != 'black')
				FlxG.sound.playMusic(Paths.music('gameOver' + stageSuffix));
			else
				FlxG.sound.playMusic(Paths.music('gameOverEmpty' + stageSuffix));


			startVibin = true;
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
	}

	override function beatHit()
	{
		super.beatHit();

		if (startVibin && !isEnding)
		{
			bf.playAnim('deathLoop', true);
		}
		FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function endBullshit():Void
	{
		if (!isEnding)
		{
			PlayState.startTime = 0;
			isEnding = true;
			bf.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			if(PlayState.SONG.player2 != 'black')
				FlxG.sound.play(Paths.music('gameOverEnd' + stageSuffix));
			else
				FlxG.sound.play(Paths.music('gameOverEndEmpty' + stageSuffix));
			
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					LoadingState.loadAndSwitchState(new PlayState());
				});
			});
		}
	}
}
