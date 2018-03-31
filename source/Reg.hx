package;

import flixel.util.FlxSave;
import flixel.tile.FlxTilemap;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.effects.FlxSpriteFilter;
import flixel.group.FlxGroup;

/**
 * Handy, pre-built Registry class that can be used to store 
 * references to objects and other things for quick-access. Feel
 * free to simply ignore it or change it in any way you like.
 */
class Reg
{
	/**
	 * Generic levels Array that can be used for cross-state stuff.
	 * Example usage: Storing the levels of a platformer.
	 */
	public static var levels:Array<Dynamic> = [];
	/**
	 * Generic level variable that can be used for cross-state stuff.
	 * Example usage: Storing the current level number.
	 */
	public static var level:Int = 0;
	/**
	 * Generic scores Array that can be used for cross-state stuff.
	 * Example usage: Storing the scores for level.
	 */
	public static var scores:Array<Dynamic> = [];
	/**
	 * Generic score variable that can be used for cross-state stuff.
	 * Example usage: Storing the current score.
	 */
	public static var score:Int = 0;
	/**
	 * Generic bucket for storing different FlxSaves.
	 * Especially useful for setting up multiple save slots.
	 */
	public static var saves:Array<FlxSave> = [];
	
	public static var text:FlxText;
	public static var sprite:FlxSprite;
	public static var button:FlxButton;
	
	public static var dkLogo="assets/images/DKGTitleLogo.png";
	public static var dkLogoSp:FlxSprite;
	
	public static var gametitle = "assets/images/title.png";
	
	public static var playerBase="assets/images/low_body.png";
	public static var playerTop="assets/images/upper_body.png";
	public static var playerAttack="assets/images/att_arm.png";
	public static var playerBaseSp:PlayerBase;
	public static var playerTopSp:PlayerTop;
	public static var playerAttackSp:PlayerAttack;
	public static var testPlayerSp:TestPlayer;
	
	public static var fireBall = "assets/images/fire_walk.png";
	
	public static var crackedRock="assets/images/crack_block.png";
	public static var dirtClod="assets/images/dirt.png";
	
	#if linux
	public static var buttonO="Space";
	public static var buttonU="Q";
	public static var buttonY="G";
	public static var buttonA="Z";
	public static var buttonDPad="Arrows";
	//public static var buttonO="O";
	//public static var buttonU="U";
	//public static var buttonY="Y";
	//public static var buttonA="A";
	//public static var buttonDPad="DPad";
	#elseif mobile
	public static var buttonO="O";
	public static var buttonU="U";
	public static var buttonY="Y";
	public static var buttonA="A";
	public static var buttonDPad="DPad";
	#else
	public static var buttonO="Space";
	public static var buttonU="Q";
	public static var buttonY="G";
	public static var buttonA="Z";
	public static var buttonDPad="Arrows";
	#end
}
