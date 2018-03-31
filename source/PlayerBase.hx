package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.ui.FlxButton;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.XboxButtonID;
import flixel.input.gamepad.OUYAButtonID;

/**
 * ...
 * @author .:BuzzJeux:.
 */
enum BaseMoveDirection
{
	UP;
	DOWN;
	LEFT;
	RIGHT;
}

enum BaseStatus
{
	ATTACK;
	STUN;
	PUDDLE;
	IDLE;
}

class PlayerBase extends FlxSprite
{
	/**
	 * How big the tiles of the tilemap are.
	 */
	private static inline var TILE_SIZE:Int = 16;
	/**
	 * How many pixels to move each frame. Has to be a divider of TILE_SIZE 
	 * to work as expected (move one block at a time), because we use the
	 * modulo-operator to check whether the next block has been reached.
	 */
	private static inline var MOVEMENT_SPEED:Int = 1;
	/**
	 * Flag used to check if char is moving.
	 */ 
	public var moveToNextTile:Bool;
	/**
	 * Var used to hold moving direction.
	 */ 
	public var moveDirection:BaseMoveDirection;
	public var status:BaseStatus;
	
	private var _gamePad:FlxGamepad;
	private var puddleTimer:Int = 0;
	private var attackTimer:Int = 0;
	
	public function new(X:Int, Y:Int)
	{
		// X,Y: Starting coordinates
		super(X, Y);
		
		// Make the player graphic.
		//makeGraphic(TILE_SIZE, TILE_SIZE, 0xffc04040);
		loadGraphic(Reg.playerBase, true, 16, 16);
		
		animation.add("walkdown", [1, 0, 1, 2], 4, true);
		animation.add("walkright", [4, 3, 4, 5], 4, true);
		animation.add("walkleft", [7, 6, 7, 8], 4, true);
		animation.add("walkup", [10, 9, 10, 11], 4, true);
		animation.add("die", [12,13,14,15,16,17], 12, true);
		animation.add("puddle", [18,19,20,21,22,23], 12, false);
		animation.add("puddlewander", [22,23], 4, true);
		
		animation.play("walkdown");
		moveDirection = BaseMoveDirection.DOWN;
		
		health = 4;
		status = BaseStatus.IDLE;
	}
	
	override public function update():Void
	{
		super.update();  
		
		_gamePad = FlxG.gamepads.lastActive;
		if (_gamePad == null)
		{
			// Make sure we don't get a crash on neko when no gamepad is active
			_gamePad = FlxG.gamepads.getByID(0);
		}
		
		// Move the player to the next bloc
		if (status != BaseStatus.ATTACK)
		{
			if (moveToNextTile)
			{
				switch (moveDirection)
				{
					case UP:
						y -= MOVEMENT_SPEED;
						if (status != BaseStatus.PUDDLE)
						{
							animation.play("walkup");
						}
					case DOWN:
						y += MOVEMENT_SPEED;
						if (status != BaseStatus.PUDDLE)
						{
							animation.play("walkdown");
						}
					case LEFT:
						x -= MOVEMENT_SPEED;
						if (status != BaseStatus.PUDDLE)
						{
							animation.play("walkleft");
						}
					case RIGHT:
						x += MOVEMENT_SPEED;
						if (status != BaseStatus.PUDDLE)
						{
							animation.play("walkright");
						}
				}
			}
		}
			
			// Check for WASD or arrow key presses and move accordingly
		if (FlxG.keys.anyPressed(["DOWN", "S"]) #if (mobile) || _gamePad.hat.y > 0 #elseif (linux) || _gamePad.pressed(GamepadIDs.DPAD_DOWN) #else #end )
		{
			moveTo(BaseMoveDirection.DOWN);
		}
		else if (FlxG.keys.anyPressed(["UP", "W"]) #if (mobile) ||  _gamePad.hat.y < 0 #elseif (linux) || _gamePad.pressed(GamepadIDs.DPAD_UP) #else #end )
		{
			moveTo(BaseMoveDirection.UP);
		}
		else if (FlxG.keys.anyPressed(["LEFT", "A"]) #if (mobile) || _gamePad.hat.x < 0 #elseif (linux) || _gamePad.pressed(GamepadIDs.DPAD_LEFT) #else #end )
		{
			moveTo(BaseMoveDirection.LEFT);
		}
		else if (FlxG.keys.anyPressed(["RIGHT", "D"]) #if (mobile) || _gamePad.hat.x > 0 #elseif (linux) || _gamePad.pressed(GamepadIDs.DPAD_RIGHT) #else #end )
		{
			moveTo(BaseMoveDirection.RIGHT);
		}
		else
		{
			stopMove();
		}
		if (FlxG.keys.anyPressed(["Z"]) || #if (mobile) _gamePad.pressed(GamepadIDs.B) #else _gamePad.pressed(GamepadIDs.B) #end )
		{
			status = BaseStatus.PUDDLE;
			animation.play("puddle");
			puddleTimer = 60;
		}
		if (FlxG.keys.anyPressed(["SPACE"]) || #if (mobile) _gamePad.pressed(GamepadIDs.A) #else _gamePad.pressed(GamepadIDs.A) #end )
		{
			status = BaseStatus.ATTACK;
			attackTimer = 30;
		}
		if (status == BaseStatus.ATTACK)
		{
			if (attackTimer > 0) {
				attackTimer--;
			} else {
				stopMove();
				status = BaseStatus.IDLE;
			}
		}
		if (status == BaseStatus.PUDDLE)
		{
			if (puddleTimer > 30) {
				puddleTimer--;
			} 
			else if (puddleTimer <= 30 && puddleTimer > 0)
			{
				animation.play("puddlewander");
				puddleTimer--;
			}
			else if (puddleTimer <= 0){
				status = BaseStatus.IDLE;
				switch (moveDirection)
				{
					case UP:
						animation.play("walkup");
					case DOWN:
						y += MOVEMENT_SPEED;
						animation.play("walkdown");
					case LEFT:
						x -= MOVEMENT_SPEED;
						animation.play("walkleft");
					case RIGHT:
						x += MOVEMENT_SPEED;
						animation.play("walkright");
				}
			}
		}
	}
	
	public function moveTo(Direction:BaseMoveDirection):Void
	{
		// Only change direction if not already moving
		if (!moveToNextTile)
		{
			moveDirection = Direction;
			moveToNextTile = true;
		}
	}
	public function stopMove(move:Bool=false):Void
	{
		// Only change direction if not already moving
		moveToNextTile = false;
	}
	
	public function shiftBase():Void
	{
		switch (moveDirection)
		{
			case UP:
				y++;
			case DOWN:
				y--;
			case LEFT:
				x++;
			case RIGHT:
				x--;
		}
	}
	
	public function takeDamage(damage:Int):Void
	{
		health--;
		
	}
	
	public function checkPuddle():Bool
	{
		return status == BaseStatus.PUDDLE;
	}
	
	public function playPuddle():Void
	{
		animation.play("puddle");
		puddleTimer = 300;
		status = BaseStatus.PUDDLE;
	}
}
