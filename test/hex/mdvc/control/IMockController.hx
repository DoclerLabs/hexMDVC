package hex.mdvc.control;

import hex.control.async.Expect;
import hex.control.async.Nothing;

/**
 * @author Francis Bourre
 */
interface IMockController
{
	function print() : Expect<Nothing>;
	function say( text : String, sender : CommandTriggerTest ) : Expect<String>;
	function sum( a : Int, b : Int ) : Int ;
}