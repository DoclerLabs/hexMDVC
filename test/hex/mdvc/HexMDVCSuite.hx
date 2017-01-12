package hex.mdvc;

import hex.mdvc.control.MDVCControlSuite;
import hex.mdvc.driver.MDVCDriverSuite;
import hex.mdvc.proxy.MDVCProxySuite;
import hex.mdvc.view.MDVCViewSuite;

/**
 * ...
 * @author Francis Bourre
 */
class HexMDVCSuite
{
	@Suite( "HexMDVC" )
    public var list : Array<Class<Dynamic>> = [ MDVCControlSuite, MDVCDriverSuite, MDVCProxySuite, MDVCViewSuite ];
}
