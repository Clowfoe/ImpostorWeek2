import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.system.FlxSound;
import flixel.FlxSprite;

class AmongButton extends FlxSprite
{ 
  public var spriteOne:FlxSprite;
  public var spriteTwo:FlxSprite;
  public var trueText:String;
  public var selected:Bool = false;
  public var trueX:Float;
  public var trueY:Float;
  
  public var func:Void->Void;

  public function new(_x:Float,_y:Float, buttonText:String = 'button')
    {
        super(-100, -100);

        trueX = _x;
        trueY = _y;

        trueText = buttonText;

        spriteOne = new FlxSprite(trueX, trueY).loadGraphic(Paths.image('menu/idlebutton', 'impostor'));
        spriteTwo = new FlxSprite(trueX, trueY).loadGraphic(Paths.image('menu/hoverbutton', 'impostor'));

        spriteOne.antialiasing = true;
        spriteTwo.antialiasing = true;
        
        spriteTwo.alpha = 0;
        spriteOne.alpha = 1;
    }

    override function update(elapsed)
     {
         super.update(elapsed);
         spriteTwo.x = spriteOne.x;
         spriteTwo.y = spriteOne.y;
     }

    public function highlight()
    {
        spriteTwo.alpha = 1;
        spriteOne.alpha = 0;
    }

    public function unHighlight()
    {
        spriteTwo.alpha = 0;
        spriteOne.alpha = 1;
    }

}