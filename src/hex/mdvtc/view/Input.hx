package hex.mdvtc.control.view;

import hex.mdvtc.model.IOutput;

/**
 * ...
 * @author Francis Bourre
 */
class Input<T> implements IInput<T>
{
	private var _output<T> : IOutput<T>;
	
	function new() 
	{
		
	}
	
	public function switchOn() : Void
	{
		this._output.connect( this );
	}
	
	public function switchOff() : Void
	{
		this._output.disconnect( this );
	}
	
}