package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.XboxButtonID;
import flixel.input.gamepad.OUYAButtonID;

/**
 * A FlxState which can be used for the game's menu.
 */
class WinState extends FlxState
{
	private var _gamePad:FlxGamepad;
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		super.create();
		
		Reg.text = new FlxText(0,10,480,"You Got Gargle Home!");
		Reg.text.size = 16;
		Reg.text.alignment = "center";
		add(Reg.text); 
		
		Reg.text = new FlxText(0,100,480,"Press "+Reg.buttonO+" to Play Again");
		Reg.text.size = 16;
		Reg.text.alignment = "center";
		add(Reg.text); 
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
		if (FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.SPACE || _gamePad.justPressed(GamepadIDs.A))
		{
			this.goToPlay();
		}
		if (FlxG.keys.justPressed.X || _gamePad.justPressed(GamepadIDs.Y))
		{
			this.goToMenu();
		}
	}	
	
	private function goToPlay():Void
	{
		FlxG.switchState(new PlayState());
	}
	
	private function goToMenu():Void
	{
		FlxG.switchState(new MenuState());
	}
}