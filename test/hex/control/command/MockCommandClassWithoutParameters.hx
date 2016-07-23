package hex.control.command;

import hex.control.command.Command;

/**
 * ...
 * @author Francis Bourre
 */
class MockCommandClassWithoutParameters extends Command<Void>
{
	public static var callCount : UInt = 0;
	
	public function new() 
	{
		trace('MockOrderClassWithoutParameters');
		super();
	}
	
	public function execute() : Void
	{
		MockCommandClassWithoutParameters.callCount++;
	}
}