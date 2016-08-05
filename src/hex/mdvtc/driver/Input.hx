package hex.mdvtc.driver;

import hex.mdvtc.model.IOutput;

/**
 * ...
 * @author Francis Bourre
 */
class Input<T> implements IInput<T>
{
	private var _driver : T;
	private var _output : IOutput<T>;
	
	public function new( driver : T ) 
	{
		this._driver = driver;
	}
	
	public function switchOn() : Void
	{
		this._output.connect( this._driver );
	}
	
	public function switchOff() : Void
	{
		this._output.disconnect( this._driver );
	}
	
	public function plug( output : IOutput<T>, switchOn : Bool = true ) : Void
	{
		if ( this._output != null )
		{
			this._output.disconnect( this._driver );
		}
		
		this._output = output;
		
		if ( switchOn )
		{
			this._output.connect( this._driver );
		}
	}
}