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
enum MoveDirection
{
	UP;
	DOWN;
	LEFT;
	RIGHT;
}

class Player extends FlxSprite
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
	#if mobile
	private static inline var MOVEMENT_SPEED:Int = 2;
	#else
	private static inline var MOVEMENT_SPEED:Int = 1;
	#end
	/**
	 * Flag used to check if char is moving.
	 */ 
	public var moveToNextTile:Bool;
	/**
	 * Var used to hold moving direction.
	 */ 
	private var moveDirection:MoveDirection;
	
	private var _gamePad:FlxGamepad;
	
	public function new(X:Int, Y:Int)
	{
		// X,Y: Starting coordinates
		super(X, Y);
		
		// Make the player graphic.
		//makeGraphic(TILE_SIZE, TILE_SIZE, 0xffc04040);
		loadGraphic(Reg.playerBase, true, 32, 32);
		
		animation.add("walkdown", [1, 0, 1, 2], 4, true);
		animation.add("walkright", [4, 3, 4, 5], 4, true);
		animation.add("walkleft", [7, 6, 7, 8], 4, true);
		animation.add("walkup", [10, 9, 10, 11], 4, true);
		animation.add("attackdown", [12, 13, 14, 15, 16, 17], 12, false);
		animation.add("attackright", [18, 19, 20, 21, 22, 23], 12, false);
		animation.add("attackleft", [24, 25, 26, 27, 28, 29], 12, false);
		animation.add("attackup", [30, 31, 32, 33, 34, 35], 12, false);
		animation.add("puddle", [36,37,38,39,40,41,42], 12, false);
		animation.add("die", [43,44,45,46,47], 12, false);
		animation.add("puddlewander", [42], 4, true);
		
		animation.play("walkdown");
		//moveDirection = MoveDirection.UP;
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
		
		// Move the player to the next block
		if (!Reg.watchFlag)
		{
			if (moveToNextTile)
			{
				switch (moveDirection)
				{
					case UP:
						y -= MOVEMENT_SPEED;
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
			
			// Check if the player has now reached the next block
			if ((x % TILE_SIZE == 0) && (y % TILE_SIZE == 0))
			{
				moveToNextTile = false;
			}
			
			/*if (y > 576)
			{
				moveToNextTile = false;
				y = 576;
			}*/
			// Check for WASD or arrow key presses and move accordingly
			if (FlxG.keys.anyPressed(["DOWN", "S"]) || #if (mobile) _gamePad.hat.y > 0 #else _gamePad.pressed(GamepadIDs.DPAD_DOWN) #end)
			{
				moveTo(MoveDirection.DOWN);
			}
			else if (FlxG.keys.anyPressed(["UP", "W"]) || #if (mobile) _gamePad.hat.y < 0 #else _gamePad.pressed(GamepadIDs.DPAD_UP) #end)
			{
				moveTo(MoveDirection.UP);
			}
			else if (FlxG.keys.anyPressed(["LEFT", "A"]) || #if (mobile) _gamePad.hat.x < 0 #else _gamePad.pressed(GamepadIDs.DPAD_LEFT) #end)
			{
				moveTo(MoveDirection.LEFT);
			}
			else if (FlxG.keys.anyPressed(["RIGHT", "D"]) || #if (mobile) _gamePad.hat.x > 0 #else _gamePad.pressed(GamepadIDs.DPAD_RIGHT) #end)
			{
				moveTo(MoveDirection.RIGHT);
			}
		}
	}
	
	public function moveTo(Direction:MoveDirection):Void
	{
		// Only change direction if not already moving
		if (!moveToNextTile)
		{
			moveDirection = Direction;
			moveToNextTile = true;
		}
	}
}
