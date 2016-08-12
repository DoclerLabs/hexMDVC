package hex.mdvc.proxy;

/**
 * ...
 * @author Francis Bourre
 */
class MDVCProxySuite
{
	@Suite( "Proxy" )
    public var list : Array<Class<Dynamic>> = [ ProxyTest ];
}