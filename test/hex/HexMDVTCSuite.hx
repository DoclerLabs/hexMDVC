package hex;

import hex.control.CommandTriggerTest;

/**
 * ...
 * @author Francis Bourre
 */
class HexMDVTCSuite
{
	@Suite( "HexMDVTC" )
    public var list : Array<Class<Dynamic>> = [ CommandTriggerTest ];
}
