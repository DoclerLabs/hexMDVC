package hex.mdvc.control;

import haxe.Timer;

/**
 * ...
 * @author Francis Bourre
 */
class MockCommandClassWithParameters extends Command<String>
{
	//@Inject
	public var message : String;
	
	//@Inject
	public var test : CommandTriggerTest;
	
	public static var callCount 	: UInt = 0;
	public static var sender 		: CommandTriggerTest = null;
	
	@Inject
	public function new( text : String, sender : CommandTriggerTest ) 
	{
		super();
		this.message 	= text;
		MockCommandClassWithParameters.sender = sender;
	}
	
	override public function execute() : Void
	{
		MockCommandClassWithParameters.callCount++;
		MockCommandClassWithParameters.sender = sender;
		
		Timer.delay( this._end, 50 );
	}
	
	function _end() : Void
	{
		this._complete( this.message );
	}
}