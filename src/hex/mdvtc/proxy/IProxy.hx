package hex.mdvtc.proxy;

/**
 * @author Francis Bourre
 */
interface IProxy<T> 
{
	function proxy( target : T ) : Void;
}