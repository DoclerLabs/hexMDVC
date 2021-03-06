package hex.mdvc.control;

import haxe.Timer;

/**
 * ...
 * @author Francis Bourre
 */
class MockCommandClassWithParameters extends Command<String>
{
	var _message : String;
	
	public static var callCount 	: UInt = 0;
	public static var sender 		: CommandTriggerTest = null;
	
	public function new() 
	{
		super();
	}
	
	public function execute( text : String, sender : CommandTriggerTest ) : Void
	{
		MockCommandClassWithParameters.callCount++;
		MockCommandClassWithParameters.sender = sender;
		
		this._message = text;
		Timer.delay( this._end, 50 );
	}
	
	function _end() : Void
	{
		this.complete( this._message );
	}
}