package hex.mdvc.control;

/**
 * ...
 * @author Francis Bourre
 */
class MDVCControlSuite
{
	@Suite( "Control" )
    public var list : Array<Class<Dynamic>> = [ CommandTriggerTest ];
}