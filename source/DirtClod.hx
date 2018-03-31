package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.util.FlxRandom;
import flixel.util.FlxCollision;

/**
 * Class declaration for the squid monster class
 */
class DirtClod extends FlxSprite
{	
	private var hero:PlayerBase;
	private var damageTicks:Int = 0;
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
		loadGraphic(Reg.dirtClod, true, 16, 16);		
		
		animation.add("health4", [0], 1);
		animation.add("health3", [1], 1);
		animation.add("health2", [2], 1);
		animation.add("health1", [3], 1);
		// Now that the animation is set up, it's very easy to play it back!
		animation.play("health4");
		
		health = 2;
		
	}
	
	/**
	 * Basic game loop is BACK y'all
	 */
	override public function update():Void
	{
		super.update();
		if (FlxCollision.pixelPerfectCheck(this, hero)) 
		{	
			hero.stopMove();
			hero.shiftBase();
		}
		switch(health)
		{
			case 4:
				animation.play("health4");
			case 3:
				animation.play("health3");
			case 2:
				animation.play("health2");
			case 1:
				animation.play("health1");
			case 0:
				kill();
		}
		
		if (damageTicks > 0) {
			damageTicks--;
		} 
	}
	
	public function takeDamage():Void
	{
		if (damageTicks <= 0)
		{
			health--;
			damageTicks = 30;
		}
	}
}
