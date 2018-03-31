package ;
import flixel.FlxSprite;
import flixel.tile.FlxTilemap;
import flixel.util.FlxPath;
import flixel.util.FlxPoint;
import flixel.util.FlxCollision;
import flixel.FlxG;
import flixel.util.FlxRandom;
/**
 * Enemy
 * @author Kirill Poletaev
 */
enum FireMoveDirection
{
	UP;
	DOWN;
	LEFT;
	RIGHT;
}

enum FireStatus
{
	WANDER;
	CHARGE;
	ATTACK;
	STUN;
	STOP;
	GRAB;
}

class FireBall extends FlxSprite
{
	public var path:FlxPath;
	private var wanderTicks:Int;
	private var stunTicks:Int;
	//private var tilemap:FlxTilemap;
	private var hero:PlayerBase;
	public var heroTop:PlayerTop;
	private var moveDirection:FireMoveDirection;
	private var status:FireStatus;
	private var MOVEMENT_SPEED:Int = 1;
	private var ATTACK_SPEED:Int = 2;
	private var chargeTicks:Float = 0;
	private var grabTicks:Float = 0;

	public function new(X:Int, Y:Int, hero:PlayerBase)//tilemap:FlxTilemap, hero:FlxSprite) 
	{
		super(X,Y);
		
		//this.tilemap = tilemap;
		this.hero = hero;
		
		loadGraphic(Reg.fireBall, true, 16, 16);
		
		animation.add("down", [1,0,1,2], 4, true);
		animation.add("up", [5,4,5,6], 4, true);
		animation.add("right", [9,8,9,10], 4, true);
		animation.add("left", [13, 12, 13, 14], 4, true);
		
		
		
		switch(Std.int(Math.random() * 4))
		{
			case 0:
				moveDirection = FireMoveDirection.UP;
				animation.play("up");
			case 1:
				moveDirection = FireMoveDirection.DOWN;
				animation.play("down");
			case 2:
				moveDirection = FireMoveDirection.LEFT;
				animation.play("left");
			case 3:
				moveDirection = FireMoveDirection.RIGHT;
				animation.play("right");
		}
		status = FireStatus.WANDER;
		wanderTicks = Std.int(Math.random() * 300);
		health = 1;
	}
	
	override public function update() {
		super.update();
		
		if (alive)
		{
			if (status == FireStatus.WANDER)
			{
				switch (moveDirection)
				{
					case UP:
						y -= MOVEMENT_SPEED;
						animation.play("up");
					case DOWN:
						y += MOVEMENT_SPEED;
						animation.play("down");
					case LEFT:
						x -= MOVEMENT_SPEED;
						animation.play("left");
					case RIGHT:
						x += MOVEMENT_SPEED;
						animation.play("right");
				}
				
				if (wanderTicks > 0) {
					wanderTicks--;
				} else {
					stopWander();
					wanderTicks = Std.int(Math.random() * 60);
				}
				seePlayer();
			}
			
			if (status == FireStatus.ATTACK)
			{
				switch (moveDirection)
				{
					case UP:
						y -= ATTACK_SPEED;
					case DOWN:
						y += ATTACK_SPEED;
					case LEFT:
						x -= ATTACK_SPEED;
					case RIGHT:
						x += ATTACK_SPEED;
				}
				/*if (FlxCollision.pixelPerfectCheck(this, hero)) 
				{	
					startStun();
					stunTicks = 30;
				}*/
			}
			
			if (status == FireStatus.CHARGE)
			{
				switch (moveDirection)
				{
					case UP:
						//animation.play("charge_up");
					case DOWN:
						//animation.play("charge_down");
					case LEFT:
						//animation.play("charge_left");
					case RIGHT:
						//animation.play("charge_right");
				}
				
				if (chargeTicks > 0) {
					chargeTicks--;
				} else {
					status = FireStatus.ATTACK;
					switch (moveDirection)
					{
						case UP:
							//animation.play("attack_up");
						case DOWN:
							//animation.play("attack_down");
						case LEFT:
							//animation.play("attack_left");
						case RIGHT:
							//animation.play("attack_right");
					}
				}
			}
			
			if (status == FireStatus.STUN)
			{
				if (stunTicks > 0) {
					stunTicks--;
				} else {
					stopWander();
				}
			}
			
			if (status == FireStatus.GRAB)
			{
				x = hero.x + FlxRandom.sign() * FlxRandom.intRanged(0,3);
				y = hero.y + FlxRandom.sign() * FlxRandom.intRanged(0,3);
				if (grabTicks > 0) {
					grabTicks--;
				} else {
					hero.takeDamage(1);
				}
				if (hero.checkPuddle())
				{
					status = FireStatus.WANDER;
					stopWander();
				}
			}
			
			if ((FlxCollision.pixelPerfectCheck(this, hero) || FlxCollision.pixelPerfectCheck(this, heroTop))) 
			{	
				hero.takeDamage(1);
				status = FireStatus.GRAB;
				grabTicks = 60;
			}
		}
	}
	
	public function takeDamage(damage:Int):Void
	{
		if (health > 0)
		{
			//FlxG.sound.play("assets/sounds/sword_hit.wav", 1, false);
		}
		health--;
		if (health <= 0)
		{
			kill();
		}
	}
	
	private function seePlayer():Void
	{
		switch (moveDirection)
		{
			case UP:
				if (hero.y < y && (hero.x + hero.width > x && hero.x < x + width))
				{
					//animation.play("charge_up");
					status = FireStatus.CHARGE;
					chargeTicks = 40;
				}
			case DOWN:
				if (hero.y > y && (hero.x + hero.width > x && hero.x < x + width))
				{
					//animation.play("charge_down");
					status = FireStatus.CHARGE;
					chargeTicks = 40;
				}
			case LEFT:
				if (hero.x < x && (hero.y + hero.height > y && hero.y < y + height))
				{
					//animation.play("charge_left");
					status = FireStatus.CHARGE;
					chargeTicks = 40;
				}
			case RIGHT:
				if (hero.x > x && (hero.y + hero.height > y && hero.y < y + height))
				{
					//animation.play("charge_right");
					status = FireStatus.CHARGE;
					chargeTicks = 40;
				}
		}
	}
	
	public function startStun():Void
	{
		status = FireStatus.STUN;
		//animation.play("stun");
		stunTicks = 30;
	}
	
	public function checkGrab():Bool
	{
		return status == FireStatus.GRAB;
	}
	
	public function stopWander():Void
	{
		if (status == FireStatus.CHARGE)
		{
			startStun();
		}
		else
		{
			status = FireStatus.STOP;
			switch(Std.int(Math.random() * 4))
			{
				case 0:
					moveDirection = FireMoveDirection.UP;
				case 1:
					moveDirection = FireMoveDirection.DOWN;
				case 2:
					moveDirection = FireMoveDirection.LEFT;
				case 3:
					moveDirection = FireMoveDirection.RIGHT;
			}
			status = FireStatus.WANDER;
		}
	}
	
	public function shiftFire():Void
	{
		switch (moveDirection)
		{
			case UP:
				y++;
				y++;
			case DOWN:
				y--;
				y--;
			case LEFT:
				x++;
				x++;
			case RIGHT:
				x--;
				x--;
		}
	}
}
