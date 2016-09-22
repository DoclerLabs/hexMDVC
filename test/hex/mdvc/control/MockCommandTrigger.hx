package hex.mdvc.control;

import hex.control.ICompletable;
import hex.control.Responder;

/**
 * ...
 * @author Francis Bourre
 */
class MockCommandTrigger extends CommandTrigger implements IMockCommandTrigger
{
	public function new()
	{
		super();
	}
	
	@Map( hex.mdvc.control.MockCommandClassWithoutParameters )
	public function print() : ICompletable<Void> { return null; }
	
	@Map( hex.mdvc.control.MockCommandClassWithParameters )
	public function say( text : String, sender : CommandTriggerTest ) : Responder<String> { return null; }

	public function sum( a : Int, b : Int ) : Int 
	{ 
		return a + b;
	}
}