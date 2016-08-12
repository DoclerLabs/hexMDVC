package hex.mdvc.model;

/**
 * @author Francis Bourre
 */
interface IOutput<Connection> 
{
	function connect( input : Connection ) : Bool;
	function disconnect( input : Connection ) : Bool;
}