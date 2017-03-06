package hex.mdvc.control;

import hex.control.async.Nothing;

/**
 * ...
 * @author Francis Bourre
 */
class MockCommandClassWithoutParameters extends Command<Nothing>
{
	public static var callCount : UInt = 0;
	
	public function new() 
	{
		super();
	}
	
	override public function execute() : Void
	{
		MockCommandClassWithoutParameters.callCount++;
	}
}