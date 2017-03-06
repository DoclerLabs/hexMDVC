package hex.mdvc.control;

import hex.control.async.IAsyncCallback;
import hex.control.async.Nothing;

/**
 * @author Francis Bourre
 */
interface IMockController
{
	function print() : IAsyncCallback<Nothing>;
	function say( text : String, sender : CommandTriggerTest ) : IAsyncCallback<String>;
	function sum( a : Int, b : Int ) : Int ;
}