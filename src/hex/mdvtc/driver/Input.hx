package hex.mdvtc.driver;

import hex.mdvtc.model.IOutput;

/**
 * ...
 * @author Francis Bourre
 */
class Input<Connection> implements IInput<Connection>
{
	private var _driver : Connection;
	private var _outputs : Array<IOutput<Connection>> = [];
	
	public function new( driver : Connection ) 
	{
		this._driver = driver;
	}
	
	public function switchOn() : Void
	{
		for ( output in this._outputs ) output.connect( this._driver );
	}
	
	public function switchOff() : Void
	{
		for ( output in this._outputs ) output.disconnect( this._driver );
	}
	
	public function plug( output : IOutput<Connection>, switchOn : Bool = true ) : Void
	{
		if ( this._outputs.indexOf( output ) == -1 )
		{
			this._outputs.push( output );
		}
		
		if ( switchOn )
		{
			output.connect( this._driver );
		}
	}
	
	public function unplug( output : IOutput<Connection> ) : Void
	{
		if ( this._outputs.indexOf( output ) != -1 )
		{
			this._outputs.remove( output );
		}
		
		output.disconnect( this._driver );
	}
}