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
enum TopMoveDirection
{
	UP;
	DOWN;
	LEFT;
	RIGHT;
}

enum TopStatus
{
	ATTACK;
	STUN;
	PUDDLE;
	IDLE;
	WALK;
}

class PlayerTop extends FlxSprite
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
	private var moveDirection:TopMoveDirection;
	public var status:TopStatus;
	
	private var _gamePad:FlxGamepad;
	
	private var pBase:PlayerBase;
	private var attackTimer:Int = 0;
	private var puddleTimer:Int = 0;
	
	public function new(base:PlayerBase)
	{
		// X,Y: Starting coordinates
		super(base.x-8, base.y-15);
		pBase = base;
		// Make the player graphic.
		//makeGraphic(TILE_SIZE, TILE_SIZE, 0xffc04040);
		loadGraphic(Reg.playerTop, true, 32, 16);
		
		
		animation.add("walkdown", [1, 0, 1, 2], 4, true);
		animation.add("walkright", [4, 3, 4, 5], 4, true);
		animation.add("walkleft", [7, 6, 7, 8], 4, true);
		animation.add("walkup", [10, 9, 10, 11], 4, true);
		animation.add("attackdown", [12, 13, 14, 15, 16, 17], 12, false);
		animation.add("attackright", [18, 19, 20, 21, 22, 23], 12, false);
		animation.add("attackleft", [24, 25, 26, 27, 28, 29], 12, false);
		animation.add("attackup", [30, 31, 32, 33, 34, 35], 12, false);
		animation.add("die", [36,37,38,39,40,41], 12, false);
		animation.add("puddle", [42,43,44,45,46,47], 12, false);
		animation.add("puddlewander", [47], 4, true);
		
		animation.play("walkdown");
		moveDirection = TopMoveDirection.DOWN;
		status = TopStatus.IDLE;
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
			
			if (status != TopStatus.ATTACK)
			{
				x = pBase.x - 8;
				y = pBase.y - 15;
			}
			if (status == TopStatus.WALK)
			{
				switch (moveDirection)
				{
					case UP:
						//y -= MOVEMENT_SPEED;
						animation.play("walkup");
					case DOWN:
						//y += MOVEMENT_SPEED;
						animation.play("walkdown");
					case LEFT:
						//x -= MOVEMENT_SPEED;
						animation.play("walkleft");
					case RIGHT:
						//x += MOVEMENT_SPEED;
						animation.play("walkright");
				}
			}
			
			if (status != TopStatus.ATTACK && status != TopStatus.PUDDLE)
			{
				// Check for WASD or arrow key presses and move accordingly
				if (FlxG.keys.anyPressed(["DOWN", "S"]) #if (mobile) || _gamePad.hat.y > 0 #elseif (linux) || _gamePad.pressed(GamepadIDs.DPAD_DOWN) #end )
				{
					moveTo(TopMoveDirection.DOWN);
				}
				else if (FlxG.keys.anyPressed(["UP", "W"]) #if (mobile) || _gamePad.hat.y < 0 #elseif (linux) || _gamePad.pressed(GamepadIDs.DPAD_UP) #end )
				{
					moveTo(TopMoveDirection.UP);
				}
				else if (FlxG.keys.anyPressed(["LEFT", "A"]) #if (mobile) || _gamePad.hat.x < 0 #elseif (linux) || _gamePad.pressed(GamepadIDs.DPAD_LEFT) #end )
				{
					moveTo(TopMoveDirection.LEFT);
				}
				else if (FlxG.keys.anyPressed(["RIGHT", "D"]) #if (mobile) || _gamePad.hat.x > 0 #elseif (linux) || _gamePad.pressed(GamepadIDs.DPAD_RIGHT) #end)
				{
					moveTo(TopMoveDirection.RIGHT);
				}
			}
			if (FlxG.keys.anyPressed(["SPACE"]) || #if (mobile) _gamePad.pressed(GamepadIDs.A) #else _gamePad.pressed(GamepadIDs.A) #end )
			{
				if (status != TopStatus.ATTACK)
				{
					attackTimer = 30;
					status = TopStatus.ATTACK;
					pBase.stopMove();
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
			if (FlxG.keys.anyPressed(["Z"]) || #if (mobile) _gamePad.pressed(GamepadIDs.B) #else _gamePad.pressed(GamepadIDs.B) #end )
			{
				status = TopStatus.PUDDLE;
				animation.play("puddle");
				puddleTimer = 60;
			}
			if (status == TopStatus.PUDDLE)
			{
				if (puddleTimer > 30) {
					puddleTimer--;
				} 
				else if (puddleTimer <= 30 && puddleTimer > 0)
				{
					animation.play("puddlewander");
					puddleTimer--;
				}
				else {
					status = TopStatus.IDLE;
					switch (moveDirection)
					{
						case UP:
							//y -= MOVEMENT_SPEED;
							animation.play("walkup");
						case DOWN:
							//y += MOVEMENT_SPEED;
							animation.play("walkdown");
						case LEFT:
							y += 8;
							animation.play("walkleft");
						case RIGHT:
							y += 8;
							animation.play("walkright");
					}
				}
			}
			
			if (status == TopStatus.ATTACK)
			{
				if (attackTimer > 0) {
					attackTimer--;
				} else {
					pBase.stopMove();
					status = TopStatus.IDLE;
					switch (moveDirection)
					{
						case UP:
							//y -= MOVEMENT_SPEED;
							animation.play("walkup");
						case DOWN:
							//y += MOVEMENT_SPEED;
							animation.play("walkdown");
						case LEFT:
							//x -= MOVEMENT_SPEED;
							animation.play("walkleft");
						case RIGHT:
							//x += MOVEMENT_SPEED;
							animation.play("walkright");
					}
				}
			}
	}
	
	public function playPuddle():Void
	{
		animation.play("puddle");
		pBase.playPuddle();
		puddleTimer = 300;
		status = TopStatus.PUDDLE;
	}
	
	public function moveTo(Direction:TopMoveDirection):Void
	{
		// Only change direction if not already moving
		moveDirection = Direction;
		status = TopStatus.WALK;
	}
}
