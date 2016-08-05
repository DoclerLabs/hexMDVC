package hex.mdvtc.driver;

import hex.mdvtc.model.IOutput;

/**
 * @author Francis Bourre
 */
interface IInput<T> 
{
	function switchOn() : Void;
	function switchOff() : Void;
	function plug( output : IOutput<T>, switchOn : Bool = true ) : Void;
}