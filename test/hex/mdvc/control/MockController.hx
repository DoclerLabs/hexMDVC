package hex.mdvc.control;

import hex.control.async.IAsyncCallback;
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
	public function print() : IAsyncCallback<Nothing>;
	
	@Map( hex.mdvc.control.MockCommandClassWithParameters )
	public function say( text : String, sender : CommandTriggerTest ) : IAsyncCallback<String>;

	public function sum( a : Int, b : Int ) : Int 
	{ 
		return a + b;
	}
}