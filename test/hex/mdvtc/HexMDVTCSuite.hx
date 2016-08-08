package hex.mdvtc;

import hex.mdvtc.control.MDVTCControlSuite;
import hex.mdvtc.driver.MDVTCDriverSuite;
import hex.mdvtc.model.MDVTCModelSuite;
import hex.mdvtc.proxy.MDVTCProxySuite;
import hex.mdvtc.view.MDVTCViewSuite;

/**
 * ...
 * @author Francis Bourre
 */
class HexMDVTCSuite
{
	@Suite( "HexMDVTC" )
    public var list : Array<Class<Dynamic>> = [ MDVTCControlSuite, MDVTCDriverSuite, MDVTCModelSuite, MDVTCProxySuite, MDVTCViewSuite ];
}
