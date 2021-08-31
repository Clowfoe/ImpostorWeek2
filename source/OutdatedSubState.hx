package;

import flixel.math.FlxPoint.FlxCallbackPoint;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;

class OutdatedSubState extends MusicBeatState
{
	public static var leftState:Bool = false;

	public static var needVer:String = "IDFK LOL";
	public static var currChanges:String = "dk";
	
	private var bgColors:Array<String> = [
		'#314d7f',
		'#4e7093',
		'#70526e',
		'#594465'
	];
	private var colorRotation:Int = 1;

	override function create()
	{
		super.create();
		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.screenCenter();
		if(FlxG.save.data.antialiasing)
			{
				bg.antialiasing = true;
			}
		add(bg);

		var naughty:FlxSprite = new FlxSprite();
		naughty.frames = Paths.getSparrowAtlas('MENU/naughtyMeny', 'impostor');
		naughty.animation.addByPrefix('idle', 'Screen instance 1', 24, true);
		naughty.animation.play('idle');
		naughty.updateHitbox();
		naughty.antialiasing = FlxG.save.data.antialiasing = true;
		naughty.scrollFactor.set();
		naughty.screenCenter();
		add(naughty);
	}

	override function update(elapsed:Float)
	{
		if (controls.ACCEPT && MainMenuState.nightly == "")
		{
			leftState = true;
			PlayState.naughtyToday = true;
			FlxG.switchState(new MainMenuState());
		}
		if (controls.BACK)
		{
			leftState = true;

			//lmao youre lame if you chose false
			PlayState.naughtyToday = false;
			
			FlxG.switchState(new MainMenuState());
		}
		super.update(elapsed);
	}
}
