package hex.mdvc.control;

import hex.control.ICompletable;
import hex.control.Responder;
import hex.mdvc.control.ICommandTrigger;

/**
 * @author Francis Bourre
 */
interface IMockCommandTrigger extends ICommandTrigger
{
	function print() : ICompletable<Void>;
	function say( text : String, sender : CommandTriggerTest ) : Responder<String>;
	function sum( a : Int, b : Int ) : Int ;
}