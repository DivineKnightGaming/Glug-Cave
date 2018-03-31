package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;
import flixel.FlxCamera;
import flixel.group.FlxGroup;
import flixel.util.FlxCollision;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.XboxButtonID;
import flixel.input.gamepad.OUYAButtonID;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{
	private var _level:TiledLevel;
	private var playerCam:FlxCamera;
	public var enemies:FlxGroup;
	public var crackedRocks:FlxGroup;
	public var dirtClods:FlxGroup;
	public var goalY:Int;
	public var goalX:Int;
	public var goalW:Int;
	public var goalH:Int;
	public var winTimer:Int;
	public var winGame:Bool = false;
	private var _gamePad:FlxGamepad;
	
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		super.create();
		
		enemies = new FlxGroup();
		crackedRocks = new FlxGroup();
		dirtClods = new FlxGroup();
		
		_level = new TiledLevel("assets/data/pa_level.tmx");
		// Add tilemaps
		add(_level.backgroundTiles);
		
		// Add tilemaps
		add(_level.foregroundTiles);
		
		// Load player and objects of the Tiled map
		_level.loadObjects(this);
		
		add(enemies);
		add(crackedRocks);
		add(dirtClods);
		
		Reg.playerTopSp = new PlayerTop(Reg.playerBaseSp);
		add(Reg.playerTopSp);
		
		Reg.playerAttackSp = new PlayerAttack(Reg.playerTopSp);
		add(Reg.playerAttackSp);
		
		for(i in 0...enemies.length)
		{
			cast(enemies.members[i], FireBall).heroTop = Reg.playerTopSp;
		}
		
		playerCam = new FlxCamera(0, 0, 480, 270);
		playerCam.setBounds(0, 0, 480, 544);
		playerCam.follow(Reg.playerBaseSp);
		FlxG.cameras.add(playerCam);
		playerCam.style = FlxCamera.STYLE_LOCKON;
	}
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		super.destroy();
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{
		super.update();
		_gamePad = FlxG.gamepads.lastActive;
		if (_gamePad == null)
		{
			// Make sure we don't get a crash on neko when no gamepad is active
			_gamePad = FlxG.gamepads.getByID(0);
		}
		
		if (_level.collideWithLevel(Reg.playerBaseSp))
		{
			// Resetting the movement flag if the player hits the wall 
			// is crucial, otherwise you can get stuck in the wall
			Reg.playerBaseSp.moveToNextTile = false;
			if (Reg.playerBaseSp.x % 16 == 15 || Reg.playerBaseSp.x % 16 == 14)
			{
				Reg.playerBaseSp.x++;
			}
			else if (Reg.playerBaseSp.x % 16 == 1 || Reg.playerBaseSp.x % 16 == 2)
			{
				Reg.playerBaseSp.x--;
			}
			if (Reg.playerBaseSp.y % 16 == 15 || Reg.playerBaseSp.y % 16 == 14)
			{
				Reg.playerBaseSp.y++;
			}
			else if (Reg.playerBaseSp.y % 16 == 1 || Reg.playerBaseSp.y % 16 == 2)
			{
				Reg.playerBaseSp.y--;
			}
		}
			
		for (i in 0...dirtClods.length) 
		{
			var clod = cast(dirtClods.members[i], DirtClod);
			if (FlxCollision.pixelPerfectCheck(clod, Reg.playerAttackSp) && Reg.playerAttackSp.checkAttack() && clod.alive)
			{
				// Resetting the movement flag if the player hits the wall 
				// is crucial, otherwise you can get stuck in the wall
				clod.takeDamage();
			}
		}
		
		for (i in 0...enemies.length) 
		{
			var enemy = cast(enemies.members[i], FireBall);
			if (_level.collideWithLevel(enemy))
			{
				// Resetting the movement flag if the player hits the wall 
				// is crucial, otherwise you can get stuck in the wall
				enemy.stopWander();
			}
			
			if (FlxCollision.pixelPerfectCheck(enemy, Reg.playerAttackSp) && Reg.playerAttackSp.checkAttack() && !enemy.checkGrab() ) 
			{	
				enemy.kill();
			}
			
			for (i in 0...crackedRocks.length) 
			{
				var block = cast(crackedRocks.members[i], CrackedRock);
				if (FlxCollision.pixelPerfectCheck(enemy, block))
				{
					// Resetting the movement flag if the player hits the wall 
					// is crucial, otherwise you can get stuck in the wall
					enemy.stopWander();
					enemy.shiftFire();
				}
			}
			
			for (i in 0...dirtClods.length) 
			{
				var clod = cast(dirtClods.members[i], DirtClod);
				if (FlxCollision.pixelPerfectCheck(enemy, clod))
				{
					// Resetting the movement flag if the player hits the wall 
					// is crucial, otherwise you can get stuck in the wall
					enemy.stopWander();
					enemy.shiftFire();
				}
			}
		}
		if (Reg.playerBaseSp.x >= goalX && Reg.playerBaseSp.x < goalX + goalW && Reg.playerBaseSp.y >= goalY && Reg.playerBaseSp.y < goalY + goalH)
		{
			//win game
			winTimer = 5;
			//Reg.playerBaseSp.stopMove();
			//Reg.playerTopSp.playPuddle();
			winGame = true;
		}
		
		if (winGame)
		{
			if (winTimer > 0) {
				winTimer--;
			} 
			else 
			{
				//go to win
				FlxG.switchState(new WinState());
			}
		}
		if (FlxG.keys.justPressed.G || _gamePad.justPressed(GamepadIDs.Y))
		{
			this.goToMenu();
		}
	}	
	
	private function goToMenu():Void
	{
		FlxG.switchState(new MenuState());
	}
}
