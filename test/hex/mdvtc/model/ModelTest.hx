package hex.mdvtc.model;

import hex.structures.Size;
import hex.unittest.assertion.Assert;

/**
 * ...
 * @author Francis Bourre
 */
@TestMacro
class ModelTest
{
	@Test( "test dispatchers instantiation and callbacks" )
    public function testDispatcherInstantiationAndCallbacks() : Void
    {
		var model 				= new MockModel();
		var intMockDriver 		= new IntMockDriver();
		var stringMockDriver 	= new StringMockDriver();
		
		Assert.isInstanceOf( model.size, Size, "property that is not annotated should kept its initial type and value" );
		
		model.intDispatcher.addListener( intMockDriver );
		model.stringDispatcher.addListener( stringMockDriver );
		
		IntMockDriver.reset();
		StringMockDriver.reset();
		
		model.changeAllValues( 3, "test" );
		Assert.equals( 1, IntMockDriver.callbackCallCount, "callback should have been called once" );
		Assert.equals( 1, StringMockDriver.callbackCallCount, "callback should have been called once" );
		Assert.equals( 3, IntMockDriver.callbackParam, "callback parameter should be the same" );
		Assert.equals( "test", StringMockDriver.callbackParam, "callback parameter should be the same" );
    }
}

private class MockModel implements IModel
{
    @Dispatcher
    public var intDispatcher : IIntMockListener;
	
	@Dispatcher
    public var stringDispatcher : IStringMockListener;
	
	public var size : Size = new Size( 10, 20 );

    public function new()
    {
        //
    }

    public function changeIntValue( i : Int, s : String ) : Void
    {
        this.intDispatcher.onChangeIntValue( i );
    }
	
	public function changeStringValue( i : Int, s : String ) : Void
    {
        this.stringDispatcher.onChangeStringValue( s );
    }
	
	public function changeAllValues( i : Int, s : String ) : Void
    {
        this.intDispatcher.onChangeIntValue( i );
        this.stringDispatcher.onChangeStringValue( s );
    }
}

private class IntMockDriver implements IIntMockListener
{
	public static var callbackCallCount : Int = 0;
	public static var callbackParam 	: Int = 0;
	
	public function new()
	{
		
	}
	
	static public function reset() : Void
	{
		IntMockDriver.callbackCallCount = 0;
		IntMockDriver.callbackParam = 0;
	}
	
    public function onChangeIntValue( i : Int ) : Void
	{
		IntMockDriver.callbackCallCount++;
		IntMockDriver.callbackParam = i;
	}
}

private class StringMockDriver implements IStringMockListener
{
	public static var callbackCallCount : Int 		= 0;
	public static var callbackParam 	: String 	= null;
	
	public function new()
	{
		
	}
	
	static public function reset() : Void
	{
		StringMockDriver.callbackCallCount = 0;
		StringMockDriver.callbackParam = null;
	}
	
    public function onChangeStringValue( s : String ) : Void
	{
		StringMockDriver.callbackCallCount++;
		StringMockDriver.callbackParam = s;
	}
}