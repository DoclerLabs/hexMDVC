package hex.mdvtc.driver;

import hex.mdvtc.model.IOutput;

/**
 * @author Francis Bourre
 */
interface IInput<Connection> 
{
	function switchOn() : Void;
	function switchOff() : Void;
	function plug( output : IOutput<Connection>, switchOn : Bool = true ) : Void;
}