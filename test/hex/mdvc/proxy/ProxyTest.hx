package hex.mdvc.proxy;

import hex.unittest.assertion.Assert;

/**
 * ...
 * @author Francis Bourre
 */
class ProxyTest
{
	@Test
	public function test()
	{
		var driver = new MockDriver();
		var model = new MockModel();
		
		/*driver.stringModel.proxy( model );
		Assert.equals( "test", driver.stringModel.getString() , "proxied method should return original result" );
		
		driver.intModel.proxy( model );
		Assert.equals( 3, driver.intModel.getInt() , "proxied method should return original result" );
		
		driver.fullModel.proxy( model );
		Assert.equals( "test", driver.fullModel.getString() , "proxied method should return original result" );
		Assert.equals( 3, driver.fullModel.getInt() , "proxied method should return original result" );*/
	}
}

private class MockModel
{
	public function new()
	{
		
	}
	
	public function getString() : String
	{
		return "test";
	}
	
	public function getInt() : Int
	{
		return 3;
	}
}

private class MockDriver implements IProxyOwner
{
	public function new()
	{
		
	}
	
	@Proxy( getString )
    public var stringModel ( default, never ) : IProxy<MockModel>;
	
	@Proxy( getInt )
    public var intModel ( default, never )  : IProxy<MockModel>;
	
	@Proxy( getString, getInt )
    public var fullModel ( default, never )  : IProxy<MockModel>;
}