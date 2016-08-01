package hex.mdvtc.model;

/**
 * @author Francis Bourre
 */
interface IDispatcher<T> 
{
	function addListener( listener : T ) : Void;
	function removeListener( listener : T ) : Void;
}