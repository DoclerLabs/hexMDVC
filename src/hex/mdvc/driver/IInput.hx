package hex.mdvc.driver;

import hex.event.ITrigger;

/**
 * @author Francis Bourre
 */
interface IInput<Connection> 
{
	function forwardTo( driver : Connection, switchOn : Bool = true ) : Void;
	function switchOn() : Void;
	function switchOff() : Void;
	function plug( output : ITrigger<Connection>, switchOn : Bool = true ) : Void;
	function unplug( output : ITrigger<Connection> ) : Void;
}