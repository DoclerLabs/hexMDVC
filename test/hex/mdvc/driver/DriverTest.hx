package hex.mdvc.driver;

import hex.mdvc.model.IIntConnection;
import hex.mdvc.model.IOutput;
import hex.mdvc.model.IStringConnection;
import hex.structures.Size;
import hex.unittest.assertion.Assert;

/**
 * ...
 * @author Francis Bourre
 */
class DriverTest
{
	@Test( "test constructor's code is not overwritten" )
    public function testConstructorCodeIsNotOverWritten() : Void
    {
		var mockDriver = new MockDriver();
		Assert.isNotNull( mockDriver.size, "code in the constructor should not be overwritten" );
	}
	
	@Test( "test not annotated property is not processed" )
    public function testNotAnnotatedProperty() : Void
    {
		var mockDriver = new MockDriver();
		Assert.isNull( mockDriver.anotherStringInput, "property that is not annotated should kept its initial type and value" );
	}
		
	@Test( "test input instantiation" )
    public function testInputInstantiation() : Void
    {
		var mockDriver = new MockDriver();
		Assert.isInstanceOf( mockDriver.intInput, Input, "property that is annotated should be an instance of 'Input'" );
		Assert.isInstanceOf( mockDriver.stringInput, Input, "property that is annotated should be an instance of 'Input'" );
    }
	
	@Test( "test plug and switch methods" )
    public function testPlugAndSwitchMethods() : Void
    {
		var mockDriver = new MockDriver();
		MockDriver.reset();
		
		//intInput
		var mockIntOutput = new MockIntOutput();
		
		mockDriver.intInput.plug( mockIntOutput );
		Assert.equals( mockDriver, mockIntOutput.lastDriverConnected, "driver should be connected to output after 'plug' method called" );
		Assert.isNull( mockIntOutput.lastDriverDisconnected, "driver should not be disconnected after 'plug' method called" );
		
		mockIntOutput.lastDriverConnected = null;
		mockIntOutput.lastDriverDisconnected = null;
		
		mockDriver.intInput.switchOff();
		
		Assert.equals( mockDriver, mockIntOutput.lastDriverDisconnected, "driver should be disconnected to output after 'switchOff' method called" );
		Assert.isNull( mockIntOutput.lastDriverConnected, "driver should not be connected after 'switchOff' method called" );
		
		//stringInput
		var mockStringOutput = new MockStringOutput();
		
		mockDriver.stringInput.plug( mockStringOutput, false );
		Assert.isNull( mockStringOutput.lastDriverConnected, "driver should not be connected to output after 'plug' method called with 'false' parameter" );
		Assert.isNull( mockStringOutput.lastDriverDisconnected, "driver should not be disconnected to output after 'plug' method called with 'false' parameter" );
		
		mockDriver.stringInput.switchOn();
		Assert.equals( mockDriver, mockStringOutput.lastDriverConnected, "driver should be connected to output after 'switchOn' method called" );
		Assert.isNull( mockStringOutput.lastDriverDisconnected, "driver should not be disconnected after 'switchOn' method called" );
    }
	
	@Test( "test plug two output of the same type" )
    public function testPlugTwoOutputsOfTheSameType() : Void
    {
		var mockDriver = new MockDriver();
		MockDriver.reset();
		
		var mockIntOutput = new MockIntOutput();
		mockIntOutput.lastDriverConnected = null;
		mockIntOutput.lastDriverDisconnected = null;
		
		var anotherMockIntOutput = new MockIntOutput();
		anotherMockIntOutput.lastDriverConnected = null;
		anotherMockIntOutput.lastDriverDisconnected = null;
		
		//plug
		mockDriver.intInput.plug( mockIntOutput );
		Assert.equals( mockDriver, mockIntOutput.lastDriverConnected, "driver should be connected to output after 'plug' method called" );
		Assert.isNull( mockIntOutput.lastDriverDisconnected, "driver should not be disconnected after 'plug' method called" );
		Assert.isNull( anotherMockIntOutput.lastDriverConnected, "driver should not be connected to this output" );
		Assert.isNull( anotherMockIntOutput.lastDriverDisconnected, "driver should not be disconnected from this output" );
		
		mockDriver.intInput.plug( anotherMockIntOutput );
		Assert.equals( mockDriver, mockIntOutput.lastDriverConnected, "driver should still be connected to this output" );
		Assert.isNull( mockIntOutput.lastDriverDisconnected, "driver should still not be disconnected from this output" );
		Assert.equals( mockDriver, anotherMockIntOutput.lastDriverConnected, "driver should be connected to this new output after 'plug' method called" );
		Assert.isNull( anotherMockIntOutput.lastDriverDisconnected, "driver should not be disconnected from this new output after 'plug' method called" );
	}
	
	@Test( "test unplug two output of the same type" )
    public function testUnplugTwoOutputsOfTheSameType() : Void
    {
		var mockDriver = new MockDriver();
		MockDriver.reset();
		
		var mockIntOutput = new MockIntOutput();
		var anotherMockIntOutput = new MockIntOutput();
		
		mockIntOutput.lastDriverConnected = null;
		mockIntOutput.lastDriverDisconnected = null;
		anotherMockIntOutput.lastDriverConnected = null;
		anotherMockIntOutput.lastDriverDisconnected = null;
		
		//Should be disconnected even if it was never plugged
		mockDriver.intInput.unplug( mockIntOutput );
		Assert.isNull( mockIntOutput.lastDriverConnected, "driver should not be connected to this output" );
		Assert.equals( mockDriver, mockIntOutput.lastDriverDisconnected, "driver should be disconnected from this output" );
		Assert.isNull( anotherMockIntOutput.lastDriverConnected, "driver should not be connected to this output" );
		Assert.isNull( anotherMockIntOutput.lastDriverDisconnected, "driver should not be disconnected from this output" );
		
		mockIntOutput.lastDriverConnected = null;
		mockIntOutput.lastDriverDisconnected = null;
		anotherMockIntOutput.lastDriverConnected = null;
		anotherMockIntOutput.lastDriverDisconnected = null;
		
		mockDriver.intInput.unplug( anotherMockIntOutput );
		Assert.isNull( mockIntOutput.lastDriverConnected, "driver should not be connected to this output" );
		Assert.isNull( mockIntOutput.lastDriverDisconnected, "driver should not be disconnected from this output" );
		Assert.isNull( anotherMockIntOutput.lastDriverConnected, "driver should not be connected to this output" );
		Assert.equals( mockDriver, anotherMockIntOutput.lastDriverDisconnected, "driver should be disconnected from this output" );
	}
}

private class MockDriver implements IIntConnection implements IStringConnection implements IInputOwner
{
	public static var callbackCallCount : Int = 0;
	public static var callbackParam 	: Dynamic = null;
	
	@Input
	public var intInput 			: IInput<IIntConnection>;
	
	@Input
	public var stringInput 			: IInput<IStringConnection>;
	
	public var size 				: Size;
	public var anotherStringInput 	: IInput<IStringConnection> = null;
	
	public function new()
	{
		this.size = new Size( 10, 20 );
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

private class MockIntOutput extends MockOutput<IIntConnection>
{
	public function new()
	{
		super();
	}
}

private class MockStringOutput extends MockOutput<IStringConnection>
{
	public function new()
	{
		super();
	}
}

private class MockOutput<Connection> implements IOutput<Connection>
{
	public var lastDriverConnected : Connection = null;
	public var lastDriverDisconnected : Connection = null;
	
	public function new()
	{
		//
	}
	
	public function connect( input : Connection ) : Bool
	{
		this.lastDriverConnected = input;
		return false;
	}
	
	public function disconnect( input : Connection ) : Bool
	{
		this.lastDriverDisconnected = input;
		return false;
	}
}