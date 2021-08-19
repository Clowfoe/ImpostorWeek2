package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class GameOverSubstate extends MusicBeatSubstate
{
	var bf:Boyfriend;
	var camFollow:FlxObject;

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
			default:
				daBf = 'bf';
		}

		switch (PlayState.SONG.player2)
		{
			case 'black':
				daBf = 'bf-defeat-death';
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
		add(camFollow);

		if(PlayState.SONG.player2 == 'black')
		{
			FlxG.sound.play(Paths.sound('loss-defeat', 'impostor'));
		}else{
			FlxG.sound.play(Paths.sound('fnf_loss_sfx' + stageSuffix));
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
			FlxG.sound.playMusic(Paths.music('gameOver' + stageSuffix));
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
			FlxG.sound.play(Paths.music('gameOverEnd' + stageSuffix));
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
