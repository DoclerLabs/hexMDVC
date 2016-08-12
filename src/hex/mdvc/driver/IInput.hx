package hex.mdvc.driver;

import hex.mdvc.model.IOutput;

/**
 * @author Francis Bourre
 */
interface IInput<Connection> 
{
	function switchOn() : Void;
	function switchOff() : Void;
	function plug( output : IOutput<Connection>, switchOn : Bool = true ) : Void;
	function unplug( output : IOutput<Connection> ) : Void;
}