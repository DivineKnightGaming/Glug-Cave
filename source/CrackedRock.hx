package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.util.FlxRandom;
import flixel.util.FlxCollision;

/**
 * Class declaration for the squid monster class
 */
class CrackedRock extends FlxSprite
{	
	private var hero:PlayerBase;
	private var wetTicks:Int = 0;
	/**
	 * This is the constructor for the squid monster.
	 * We are going to set up the basic values and then create a simple animation.
	 */
	public function new(X:Int, Y:Int, hero:PlayerBase)
	{
		super(X, Y);
		
		this.hero = hero;
		
		// Initialize sprite object	
		// Load this animated graphic file
		loadGraphic(Reg.crackedRock, true, 16, 16);		
		
		animation.add("dry", [0], 1);
		animation.add("wet", [1], 1);
		
		// Now that the animation is set up, it's very easy to play it back!
		animation.play("dry");
		
	}
	
	/**
	 * Basic game loop is BACK y'all
	 */
	override public function update():Void
	{
		super.update();
		if (FlxCollision.pixelPerfectCheck(this, hero) && !hero.checkPuddle()) 
		{	
			animation.play("wet");
			hero.stopMove();
			hero.shiftBase();
			wetTicks = 30;
		}
		if (FlxCollision.pixelPerfectCheck(this, hero) && hero.checkPuddle()) 
		{	
			animation.play("wet");
			wetTicks = 30;
		}
		if (wetTicks > 0) {
			wetTicks--;
		} else 
		{
			animation.play("dry");
		}
	}
}
