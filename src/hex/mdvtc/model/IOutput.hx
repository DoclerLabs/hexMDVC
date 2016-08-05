package hex.mdvtc.model;

/**
 * @author Francis Bourre
 */
interface IOutput<I> 
{
	function connect( input : I ) : Bool;
	function disconnect( input : I ) : Bool;
}