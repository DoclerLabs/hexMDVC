package hex.mdvc.control;

import hex.control.async.Expect;
import hex.control.async.Nothing;

/**
 * ...
 * @author Francis Bourre
 */
class MockController 
	implements ICommandTrigger
	implements IMockController 
{
	public function new(){}
	
	@Map( hex.mdvc.control.MockCommandClassWithoutParameters )
	public function print() : Expect<Nothing>;
	
	@Map( hex.mdvc.control.MockCommandClassWithParameters )
	public function say( text : String, sender : CommandTriggerTest ) : Expect<String>;

	public function sum( a : Int, b : Int ) : Int 
	{ 
		return a + b;
	}
}