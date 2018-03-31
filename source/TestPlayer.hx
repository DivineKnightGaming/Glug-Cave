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
enum TestMoveDirection
{
	UP;
	DOWN;
	LEFT;
	RIGHT;
}

enum TestStatus
{
	ATTACK;
	STUN;
	PUDDLE;
	IDLE;
	WALK;
}

class TestPlayer extends FlxSprite
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
	public var moveDirection:TestMoveDirection;
	public var status:TestStatus;
	
	private var _gamePad:FlxGamepad;
	private var puddleTimer:Int = 0;
	private var attackTimer:Int = 0;
	
	public function new(X:Int, Y:Int)
	{
		// X,Y: Starting coordinates
		super(X, Y);
		
		// Make the player graphic.
		//makeGraphic(TILE_SIZE, TILE_SIZE, 0xffc04040);
		loadGraphic(Reg.testPlayer, true, 16, 24);
		
		animation.add("walk", [0], 4, true);
		animation.add("attackdown", [0], 4, true);
		animation.add("attackup", [0], 4, true);
		animation.add("attackleft", [0], 4, true);
		animation.add("attackright", [0], 4, true);
		animation.add("attackright", [0], 4, true);
		
		
		animation.play("walk");
		
		offset.set(0, 8);
		width = 16;
		height = 16;
		
		moveDirection = TestMoveDirection.DOWN;
		
		health = 4;
		status = TestStatus.IDLE;
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
		if (status != TestStatus.ATTACK)
		{
			if (moveToNextTile)
			{
				switch (moveDirection)
				{
					case UP:
						y -= MOVEMENT_SPEED;
						if (status != TestStatus.PUDDLE)
						{
							animation.play("walk");
						}
					case DOWN:
						y += MOVEMENT_SPEED;
						if (status != TestStatus.PUDDLE)
						{
							animation.play("walk");
						}
					case LEFT:
						x -= MOVEMENT_SPEED;
						if (status != TestStatus.PUDDLE)
						{
							animation.play("walk");
						}
					case RIGHT:
						x += MOVEMENT_SPEED;
						if (status != TestStatus.PUDDLE)
						{
							animation.play("walk");
						}
				}
			}
		}
			
			// Check for WASD or arrow key presses and move accordingly
		if (FlxG.keys.anyPressed(["DOWN", "S"]) #if (mobile) || _gamePad.hat.y > 0 #elseif (linux) || _gamePad.pressed(GamepadIDs.DPAD_DOWN) #else #end )
		{
			moveTo(TestMoveDirection.DOWN);
		}
		else if (FlxG.keys.anyPressed(["UP", "W"]) #if (mobile) ||  _gamePad.hat.y < 0 #elseif (linux) || _gamePad.pressed(GamepadIDs.DPAD_UP) #else #end )
		{
			moveTo(TestMoveDirection.UP);
		}
		else if (FlxG.keys.anyPressed(["LEFT", "A"]) #if (mobile) || _gamePad.hat.x < 0 #elseif (linux) || _gamePad.pressed(GamepadIDs.DPAD_LEFT) #else #end )
		{
			moveTo(TestMoveDirection.LEFT);
		}
		else if (FlxG.keys.anyPressed(["RIGHT", "D"]) #if (mobile) || _gamePad.hat.x > 0 #elseif (linux) || _gamePad.pressed(GamepadIDs.DPAD_RIGHT) #else #end )
		{
			moveTo(TestMoveDirection.RIGHT);
		}
		else
		{
			stopMove();
		}
		if (FlxG.keys.anyPressed(["Z"]) || #if (mobile) _gamePad.pressed(GamepadIDs.B) #else _gamePad.pressed(GamepadIDs.B) #end )
		{
			status = TestStatus.PUDDLE;
			animation.play("puddle");
			puddleTimer = 60;
		}
		if (FlxG.keys.anyPressed(["SPACE"]) || #if (mobile) _gamePad.pressed(GamepadIDs.A) #else _gamePad.pressed(GamepadIDs.A) #end )
		{
			if (status != TestStatus.ATTACK)
			{
				attackTimer = 30;
				status = TestStatus.ATTACK;
				//pBase.stopMove();
				switch (moveDirection)
				{
					case UP:
						//y -= MOVEMENT_SPEED;
						animation.play("attackup");
					case DOWN:
						//y += MOVEMENT_SPEED;
						animation.play("attackdown");
					case LEFT:
						y += 8;
						animation.play("attackleft");
					case RIGHT:
						y += 8;
						animation.play("attackright");
				}
			}
		}
		if (status == TestStatus.ATTACK)
		{
			if (attackTimer > 0) {
				attackTimer--;
			} else {
				stopMove();
				status = TestStatus.IDLE;
			}
		}
		if (status == TestStatus.PUDDLE)
		{
			if (puddleTimer > 30) {
				puddleTimer--;
			} 
			else if (puddleTimer <= 30 && puddleTimer > 0)
			{
				animation.play("puddle");
				puddleTimer--;
			}
			else if (puddleTimer <= 0){
				status = TestStatus.IDLE;
				switch (moveDirection)
				{
					case UP:
						animation.play("walk");
					case DOWN:
						y += MOVEMENT_SPEED;
						animation.play("walk");
					case LEFT:
						x -= MOVEMENT_SPEED;
						animation.play("walk");
					case RIGHT:
						x += MOVEMENT_SPEED;
						animation.play("walk");
				}
			}
		}
	}
	
	public function moveTo(Direction:TestMoveDirection):Void
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
		return status == TestStatus.PUDDLE;
	}
	
	public function playPuddle():Void
	{
		animation.play("puddle");
		puddleTimer = 300;
		status = TestStatus.PUDDLE;
	}
}
