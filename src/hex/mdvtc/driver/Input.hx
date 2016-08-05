package hex.mdvtc.driver;

import hex.mdvtc.model.IOutput;

/**
 * ...
 * @author Francis Bourre
 */
class Input<Connection> implements IInput<Connection>
{
	private var _driver : Connection;
	private var _output : IOutput<Connection>;
	
	public function new( driver : Connection ) 
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
	
	public function plug( output : IOutput<Connection>, switchOn : Bool = true ) : Void
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