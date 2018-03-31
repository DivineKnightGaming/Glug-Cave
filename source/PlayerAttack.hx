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
enum AttackMoveDirection
{
	UP;
	DOWN;
	LEFT;
	RIGHT;
}

enum AttackStatus
{
	ATTACK;
	IDLE;
}

class PlayerAttack extends FlxSprite
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
	private var moveDirection:AttackMoveDirection;
	public var status:AttackStatus;
	
	private var _gamePad:FlxGamepad;
	
	private var pTop:PlayerTop;
	private var attackTimer:Int = 0;
	
	public function new(top:PlayerTop)
	{
		// X,Y: Starting coordinates
		super(top.x, top.y+top.height);
		pTop = top;
		// Make the player graphic.
		//makeGraphic(TILE_SIZE, TILE_SIZE, 0xffc04040);
		loadGraphic(Reg.playerAttack, true, 32, 32);
		
		
		animation.add("attackdown", [0, 1, 2, 3, 4, 5], 12, false);
		animation.add("attackright", [6, 7, 8, 9, 10, 11], 12, false);
		animation.add("attackleft", [12, 13, 14, 15, 16, 17], 12, false);
		animation.add("attackup", [18, 19, 20, 21, 22, 23], 12, false);
		animation.add("idle", [0], 6, false);
		
		animation.play("idle");
		moveDirection = AttackMoveDirection.DOWN;
		status = AttackStatus.IDLE;
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
			
			if (status != AttackStatus.ATTACK)
			{
				animation.play("idle");
				switch (moveDirection)
				{
					case UP:
						x = pTop.x;
						y = pTop.y - height;
					case DOWN:
						x = pTop.x;
						y = pTop.y + pTop.height;
					case LEFT:
						x = pTop.x - width;
						y = pTop.y;
					case RIGHT:
						x = pTop.x + pTop.width;
						y = pTop.y;
				}
				// Check for WASD or arrow key presses and move accordingly
				if (FlxG.keys.anyPressed(["DOWN", "S"]) #if (mobile) || _gamePad.hat.y > 0 #elseif (linux) || _gamePad.pressed(GamepadIDs.DPAD_DOWN) #end )
				{
					moveTo(AttackMoveDirection.DOWN);
				}
				else if (FlxG.keys.anyPressed(["UP", "W"]) #if (mobile) || _gamePad.hat.y < 0 #elseif (linux) || _gamePad.pressed(GamepadIDs.DPAD_UP) #end )
				{
					moveTo(AttackMoveDirection.UP);
				}
				else if (FlxG.keys.anyPressed(["LEFT", "A"]) #if (mobile) || _gamePad.hat.x < 0 #elseif (linux) || _gamePad.pressed(GamepadIDs.DPAD_LEFT) #end )
				{
					moveTo(AttackMoveDirection.LEFT);
				}
				else if (FlxG.keys.anyPressed(["RIGHT", "D"]) #if (mobile) || _gamePad.hat.x > 0 #elseif (linux) || _gamePad.pressed(GamepadIDs.DPAD_RIGHT) #end )
				{
					moveTo(AttackMoveDirection.RIGHT);
				}
			}
			if (FlxG.keys.anyPressed(["SPACE"]) || #if (mobile) _gamePad.pressed(GamepadIDs.A) #else _gamePad.pressed(GamepadIDs.A) #end )
			{
				if (status != AttackStatus.ATTACK)
				{
					attackTimer = 30;
					status = AttackStatus.ATTACK;
					//pTop.stopMove();
					switch (moveDirection)
					{
						case UP:
							//y -= MOVEMENT_SPEED;
							animation.play("attackup");
						case DOWN:
							//y += MOVEMENT_SPEED;
							animation.play("attackdown");
						case LEFT:
							//x -= MOVEMENT_SPEED;
							y = pTop.y;
							animation.play("attackleft");
						case RIGHT:
							//x += MOVEMENT_SPEED;
							y = pTop.y;
							animation.play("attackright");
					}
				}
			}
			
			if (status == AttackStatus.ATTACK)
			{
				if (attackTimer > 0) {
					attackTimer--;
				} else {
					status = AttackStatus.IDLE;
					animation.play("idle");
				}
			}
	}
	
	public function moveTo(Direction:AttackMoveDirection):Void
	{
		// Only change direction if not already moving
		moveDirection = Direction;
		status = AttackStatus.IDLE;
	}
	
	public function checkAttack():Bool
	{
		return status == AttackStatus.ATTACK;
	}
}
