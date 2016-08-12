package hex.mdvc.proxy;

import hex.unittest.assertion.Assert;

/**
 * ...
 * @author Francis Bourre
 */
class ProxyTest
{
	@Test( "test proxy behavior" )
	public function testProxyBehavior()
	{
		var driver = new MockDriver();
		var model = new MockModel();
		model.setData( "test", 3 );
		
		driver.stringModel.proxy( model );
		Assert.equals( "test", driver.stringModel.getString() , "proxied method should return original result" );
		
		driver.intModel.proxy( model );
		Assert.equals( 3, driver.intModel.getInt() , "proxied method should return original result" );
		
		driver.fullModel.proxy( model );
		Assert.equals( "test", driver.fullModel.getString() , "proxied method should return original result" );
		Assert.equals( 3, driver.fullModel.getInt() , "proxied method should return original result" );
		//Assert.equals( 10, driver.fullModel.getSum( 7 ) , "proxied method should return original result with passed parameteres" );
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