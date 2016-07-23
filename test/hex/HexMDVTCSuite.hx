package hex;

import hex.control.command.CommandTriggerTest;

/**
 * ...
 * @author Francis Bourre
 */
class HexMDVTCSuite
{
	@Suite( "HexMDVTC" )
    public var list : Array<Class<Dynamic>> = [ CommandTriggerTest ];
}
