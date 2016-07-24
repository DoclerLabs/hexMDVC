package hex.control;

/**
 * ...
 * @author Francis Bourre
 */
class MockCommandClassWithoutParameters extends Command<Void>
{
	public static var callCount : UInt = 0;
	
	public function new() 
	{
		super();
	}
	
	public function execute() : Void
	{
		MockCommandClassWithoutParameters.callCount++;
	}
}