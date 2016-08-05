package hex.mdvtc.driver;

import hex.mdvtc.model.IIntConnection;
import hex.mdvtc.model.IStringConnection;
import hex.structures.Size;
import hex.unittest.assertion.Assert;

/**
 * ...
 * @author Francis Bourre
 */
class DriverTest
{
	@Test( "test input instantiation and callbacks" )
    public function testInputInstantiationAndCallbacks() : Void
    {
		var mockDriver 		= new MockDriver();
		
		Assert.isInstanceOf( mockDriver.size, Size, "property that is not annotated should kept its initial type and value" );
		
		MockDriver.reset();
		Assert.isInstanceOf( mockDriver.intInput, Input, "property that is annotated should become an instance of 'Input'" );
		Assert.isInstanceOf( mockDriver.stringInput, Input, "property that is annotated should become an instance of 'Input'" );
    }
}

private class MockDriver implements IIntConnection implements IStringConnection implements IInputOwner
{
	public static var callbackCallCount : Int = 0;
	public static var callbackParam 	: Dynamic = null;
	
	@Input
	public var intInput : IInput<IIntConnection>;
	
	@Input
	public var stringInput : IInput<IStringConnection>;
	
	public var size : Size = new Size( 10, 20 );
	
	public function new()
	{
		
	}
	
	static public function reset() : Void
	{
		MockDriver.callbackCallCount = 0;
		MockDriver.callbackParam = null;
	}
	
    public function onChangeIntValue( i : Int ) : Void
	{
		MockDriver.callbackCallCount++;
		MockDriver.callbackParam = i;
	}
	
	public function onChangeStringValue( s : String ) : Void
	{
		MockDriver.callbackCallCount++;
		MockDriver.callbackParam = s;
	}
}