package;

import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
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
	var emotion:String = '';
	var dialogueList:Array<String> = [];

	// SECOND DIALOGUE FOR THE PIXEL SHIT INSTEAD???
	var swagDialogue:FlxTypeText;

	var rightChar:FlxSprite;
	var leftChar:FlxSprite;

	var rightState:String = 'neutral';
	var leftState:String = 'neutral';

	var leftTween:FlxTween;
	var rightTween:FlxTween;
	var prevSide:Bool;
	var curSide:Bool;

	public var finishThing:Void->Void;

	var handSelect:FlxSprite;

	var bgFade:FlxSprite;
	var shitground:FlxSprite;

	public function new(talkingRight:Bool = true, ?dialogueList:Array<String>, ?greenImpostor:Bool)
	{
		super();
		
		var hasDialog = false;
		hasDialog = true;

		shitground = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
		shitground.updateHitbox();
		shitground.screenCenter();
		shitground.alpha = 0;
		add(shitground);		


		box = new FlxSprite(118, 395.85).loadGraphic(Paths.image('dialogue/dialogueBox', 'impostor'));
		box.antialiasing = true;
		box.updateHitbox();
		box.active = true;
		box.screenCenter(X);
		
		rightChar = new FlxSprite(820.25, 131.95);
		rightChar.frames = Paths.getSparrowAtlas('dialogue/rightCharacter', 'impostor');
		rightChar.antialiasing = true;

		rightChar.animation.addByPrefix('b-neutral-talking', 'boyfriend neutral', 24, true);
		rightChar.animation.addByPrefix('b-happy-talking', 'boyfriend happy', 24, true);
		rightChar.animation.addByPrefix('b-mad-talking', 'boyfriend mad', 24, true);
		rightChar.animation.addByPrefix('b-shocked-talking', 'boyfriend shocked', 24, true);
		rightChar.animation.addByPrefix('b-stupid-talking', 'boyfriend stupid', 24, true);
		rightChar.animation.addByPrefix('b-angry-talking', 'boyfriend very angry', 24, true);

		rightChar.animation.addByIndices('b-happy', 'boyfriend happy', [0], "", 24, true);
		rightChar.animation.addByIndices('b-mad', 'boyfriend mad', [0], "", 24, true);
		rightChar.animation.addByIndices('b-shocked', 'boyfriend shocked', [0], "", 24, true);
		rightChar.animation.addByIndices('b-stupid', 'boyfriend stupid', [0], "", 24, true);
		rightChar.animation.addByIndices('b-angry', 'boyfriend very angry', [0], "", 24, true);
		rightChar.animation.addByIndices('b-neutral', 'boyfriend neutral', [0], "", 24, true);

		rightChar.animation.addByPrefix('gf-neutral-talking', 'girlfriend neutral', 24, true);
		rightChar.animation.addByPrefix('gf-happy-talking', 'girlfriend happy', 24, true);
		rightChar.animation.addByPrefix('gf-concern-talking', 'girlfriend concern', 24, true);
		rightChar.animation.addByPrefix('gf-raised-talking', 'girlfriend :raised_eyeborw:', 24, true);
		rightChar.animation.addByPrefix('gf-angry-talking', 'girlfreind angry', 24, true);

		rightChar.animation.addByIndices('gf-happy', 'girlfriend happy', [0], "", 24, true);
		rightChar.animation.addByIndices('gf-concern', 'girlfriend concern', [0], "", 24, true);
		rightChar.animation.addByIndices('gf-raised', 'girlfriend :raised_eyeborw:', [0], "", 24, true);
		rightChar.animation.addByIndices('gf-angry', 'girlfreind angry', [0], "", 24, true);
		rightChar.animation.addByIndices('gf-neutral', 'girlfriend neutral', [0], "", 24, true);

		rightChar.animation.play('neutral');
		add(rightChar);
		rightChar.alpha = 0;
		
		leftChar = new FlxSprite(207.15, 148.4);

		if(greenImpostor) {
			leftChar.frames = Paths.getSparrowAtlas('dialogue/greenImpostor', 'impostor');			
	
			leftChar.animation.addByPrefix('i-neutral-talking', 'green impoters neutral', 24, true);
			leftChar.animation.addByPrefix('i-happy-talking', 'green crewmate happy', 24, true);
			leftChar.animation.addByPrefix('i-nervous-talking', 'green crewmate nervous', 24, true);
			leftChar.animation.addByPrefix('i-smile-talking', 'green crewmate smile', 24, true);
			leftChar.animation.addByPrefix('i-evil-talking', 'green imposor evilous', 24, true);
			leftChar.animation.addByPrefix('i-angry-talking', 'green impostor angry', 24, true);
			leftChar.animation.addByPrefix('i-happyevil-talking', 'greenimportor happy', 24, true);
	
			leftChar.animation.addByIndices('i-happy', 'green crewmate happy', [0], "", 24, true);
			leftChar.animation.addByIndices('i-nervous', 'green crewmate nervous', [0], "", 24, true);
			leftChar.animation.addByIndices('i-smile', 'green crewmate smile', [0], "", 24, true);
			leftChar.animation.addByIndices('i-evil', 'green imposor evilous', [0], "", 24, true);
			leftChar.animation.addByIndices('i-neutral', 'green impoters neutral', [0], "", 24, true);
			leftChar.animation.addByIndices('i-angry', 'green impostor angry', [0], "", 24, true);
			leftChar.animation.addByIndices('i-happyevil', 'greenimportor happy', [0], "", 24, true);
		}
		else {
			leftChar.frames = Paths.getSparrowAtlas('dialogue/redImpostor', 'impostor');			
	
			leftChar.animation.addByPrefix('i-neutral-talking', 'impostor neutral', 24, true);
			leftChar.animation.addByPrefix('i-happy-talking', 'impostor happy', 24, true);
			leftChar.animation.addByPrefix('i-mad-talking', 'impostor mad', 24, true);
			leftChar.animation.addByPrefix('i-shocked-talking', 'impostor shocked', 24, true);
			leftChar.animation.addByPrefix('i-sex-talking', 'the secret impostor', 24, true);
	
			leftChar.animation.addByIndices('i-happy', 'impostor happy', [0], "", 24, true);
			leftChar.animation.addByIndices('i-mad', 'impostor mad', [0], "", 24, true);
			leftChar.animation.addByIndices('i-shocked', 'impostor shocked', [0], "", 24, true);
			leftChar.animation.addByIndices('i-sex', 'the secret impostor', [0], "", 24, true);
			leftChar.animation.addByIndices('i-neutral', 'impostor neutral', [0], "", 24, true);
		}		

		leftChar.antialiasing = true;
		leftChar.animation.play('i-neutral');
		leftChar.alpha = 0;

		add(leftChar);

		add(box);

		box.y += 500;

		
		this.dialogueList = dialogueList;
		
		FlxTween.tween(box, {y: box.y - 500}, 0.5, {ease: FlxEase.quadOut});
		FlxTween.tween(shitground, {alpha: 0.3}, 0.5);
		
		if (!hasDialog)
			return;
		
		
		swagDialogue = new FlxTypeText(240, 450, Std.int(FlxG.width * 0.70), "", 32);
		swagDialogue.font = Paths.font('dialogue.ttf');
		swagDialogue.color = FlxColor.BLACK;
		swagDialogue.sounds = [FlxG.sound.load(Paths.sound('pixelText'), 0.6)];
		swagDialogue.screenCenter(X);
		swagDialogue.antialiasing = true;
		add(swagDialogue);

		if(talkingRight) {
			leftTween = FlxTween.tween(leftChar, {x: 207.15 + 30, alpha: 1}, 0.3, {ease: FlxEase.quadOut});
			rightTween = FlxTween.tween(rightChar, {x: 820.15 + 30, alpha: 0}, 0.3, {ease: FlxEase.quadOut});
		}
		else {
			leftTween = FlxTween.tween(leftChar, {x: 207.15 + 30, alpha: 1}, 0.3, {ease: FlxEase.quadOut});
			rightTween = FlxTween.tween(rightChar, {x: 820.15 + 30, alpha: 0}, 0.3, {ease: FlxEase.quadOut});
		}
		
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

					FlxTween.tween(rightChar, {alpha: 0}, 0.5);
					FlxTween.tween(leftChar, {alpha: 0}, 0.5);
					FlxTween.tween(box, {alpha: 0}, 0.5);
					FlxTween.tween(swagDialogue, {alpha: 0}, 0.5);
					FlxTween.tween(shitground, {alpha: 0}, 0.5);

					new FlxTimer().start(0.7, function(tmr:FlxTimer)
					{
						finishThing();
						kill();
					});
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

	function endAnimation():Void {
		rightChar.animation.play(curCharacter + "-" + emotion);
		leftChar.animation.play(curCharacter + "-" + emotion);
	}

	var isEnding:Bool = false;

	function startDialogue():Void
	{
		cleanDialog();

		// swagDialogue.text = ;
		swagDialogue.resetText(dialogueList[0]);
		swagDialogue.start(0.04, true, false, null);
		swagDialogue.completeCallback = endAnimation;
	}

	function cleanDialog():Void
	{
		var splitName:Array<String> = dialogueList[0].split(":");
		emotion = splitName[2];
		curCharacter = splitName[1];
		switch(curCharacter) {
			case 'i':
				leftChar.animation.play(curCharacter + "-" + emotion + "-talking");
				prevSide = curSide;
				curSide = false;
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('i-text', 'impostor'), 0.6)];
			case 'b':
				rightChar.animation.play(curCharacter + "-" + emotion + "-talking");
				prevSide = curSide;
				curSide = true;
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('bf-text', 'impostor'), 0.6)];
			case 'gf':
				rightChar.animation.play(curCharacter + "-" + emotion + "-talking");
				prevSide = curSide;
				curSide = true;
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('gf-text', 'impostor'), 0.6)];
		}

		if(curSide) {
			if(curSide != prevSide) {
				rightChar.x = 820.25 + 30;
				rightChar.alpha = 0;
				if(leftTween != null) {
					leftTween.cancel();
				}
				if(rightTween != null) {
					rightTween.cancel();
				}
				rightTween = FlxTween.tween(rightChar, {x: 820.25 - 30, alpha: 1}, 0.3, {ease: FlxEase.quadOut});
				leftTween = FlxTween.tween(leftChar, {x: 207.15 - 30, alpha: 0}, 0.3, {ease: FlxEase.quadOut});
			}
		}
		else {
			if(curSide != prevSide) {
				leftChar.x = 207.15 - 30;
				leftChar.alpha = 0;
				if(leftTween != null) {
					leftTween.cancel();
				}
				if(rightTween != null) {
					rightTween.cancel();
				}
				leftTween = FlxTween.tween(leftChar, {x: 207.15 + 30, alpha: 1}, 0.3, {ease: FlxEase.quadOut});
				rightTween = FlxTween.tween(rightChar, {x: 820.15 + 30, alpha: 0}, 0.3, {ease: FlxEase.quadOut});
			}
		}

		dialogueList[0] = dialogueList[0].substr(splitName[1].length + 3 + splitName[2].length).trim();
	}
}
