package hex.mdvc.proxy;

/**
 * @author Francis Bourre
 */
interface IMockModel 
{
	function getInt() : Int;
	function getString() : String;
	function setData( s : String, i : Int ) : Void;
}