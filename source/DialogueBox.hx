package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxKeyManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

using StringTools;

class DialogueBox extends FlxSpriteGroup
{
	var box:FlxSprite;

	var curCharacter:String = '';
	var dialogueList:Array<String> = [];

	// SECOND DIALOGUE FOR THE PIXEL SHIT INSTEAD???
	var swagDialogue:FlxTypeText;

	var rightChar:FlxSprite;
	var leftChar:FlxSprite;

	var rightState:String = 'neutral';
	var leftState:String = 'neutral';

	public var finishThing:Void->Void;

	var handSelect:FlxSprite;
	var bgFade:FlxSprite;

	public function new(talkingRight:Bool = true, ?dialogueList:Array<String>)
	{
		super();
		
		var hasDialog = false;
		hasDialog = true;

		box = new FlxSprite(118, 395.85).loadGraphic(Paths.image('dialogue/dialogueBox', 'impostor'));
		box.antialiasing = true;
		box.updateHitbox();
		box.active = true;
		box.screenCenter(X);
		add(box);

		rightChar = new FlxSprite(820.25, 131.95);
		rightChar.frames = Paths.getSparrowAtlas('dialogue/boyfriend', 'impostor');
		rightChar.animation.addByPrefix('neutral-talking', 'boyfriend neutral', 24, true);
		rightChar.animation.addByIndices('neutral', 'boyfriend neutral', [0], "", 24, true);
		add(rightChar);

		leftChar = new FlxSprite(207.15, 148.4);
		leftChar.frames = Paths.getSparrowAtlas('dialogue/redImposter', 'impostor');
		leftChar.animation.addByPrefix('neutral-talking', 'impostor neutral', 24, true);
		leftChar.animation.addByIndices('neutral', 'impostor neutral', [0], "", 24, true);
		add(leftChar);

		this.dialogueList = dialogueList;

		
		if (!hasDialog)
			return;
	

		swagDialogue = new FlxTypeText(240, 500, Std.int(FlxG.width * 0.8), "", 32);
		swagDialogue.font = Paths.font('flower.ttf');
		swagDialogue.color = FlxColor.BLACK;
		swagDialogue.sounds = [FlxG.sound.load(Paths.sound('pixelText'), 0.6)];
		swagDialogue.screenCenter(X);
		add(swagDialogue);
	}

	var dialogueOpened:Bool = false;
	var dialogueStarted:Bool = false;

	override function update(elapsed:Float)
	{
		if (!dialogueStarted)
		{
			startDialogue();
			dialogueStarted = true;
		}

		if (PlayerSettings.player1.controls.ACCEPT && dialogueStarted == true)
		{			
			FlxG.sound.play(Paths.sound('clickText'), 0.8);

			if (dialogueList[1] == null && dialogueList[0] != null)
			{
				if (!isEnding)
				{
					isEnding = true;

					finishThing();
					kill();
				}
			}
			else
			{
				dialogueList.remove(dialogueList[0]);
				startDialogue();
			}
		}
		
		super.update(elapsed);
	}

	function endAnimation(right:Bool):Void {
		if(right) {
			rightChar.animation.play(rightState);
		}
		else {
			leftChar.animation.play(leftState);
		}
	}

	var isEnding:Bool = false;

	function startDialogue():Void
	{
		cleanDialog();

		// swagDialogue.text = ;
		swagDialogue.resetText(dialogueList[0]);
		swagDialogue.start(0.04, true, false, null, endAnimation(true));
	}

	function cleanDialog():Void
	{
		var splitName:Array<String> = dialogueList[0].split(":");
		curCharacter = splitName[1];
		switch(curCharacter) {
			case 'dad':
				leftChar.animation.play(leftState + "-talking");
			case 'bf':
				rightChar.animation.play(rightState + "-talking");
		}
		dialogueList[0] = dialogueList[0].substr(splitName[1].length + 2).trim();
	}
}
