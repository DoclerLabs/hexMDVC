package hex.mdvc.proxy;

/**
 * ...
 * @author Francis Bourre
 */
class MockModel implements IMockModel
{
	var _s : String;
	var _i : Int;
	
	public function new()
	{
		
	}
	
	public function setData( s : String, i : Int ) : Void
	{
		this._s = s;
		this._i = i;
	}
	
	/*public function getSum( i : Int ) : Int
	{
		return this._i + i;
	}*/
	
	public function getString() : String
	{
		return this._s;
	}
	
	public function getInt() : Int
	{
		return this._i;
	}
}