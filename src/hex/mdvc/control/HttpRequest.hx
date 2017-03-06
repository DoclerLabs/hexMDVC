package hex.mdvc.control;

import haxe.Http;
import hex.collection.HashMap;
import hex.data.IParser;
import hex.error.NullPointerException;
import hex.service.stateless.http.HTTPRequestHeader;
import hex.service.stateless.http.HTTPRequestMethod;
import hex.service.stateless.http.HTTPServiceConfiguration;
import hex.service.stateless.http.HTTPServiceParameters;
import hex.util.Stringifier;

/**
 * ...
 * @author Francis Bourre
 */
class HttpRequest<ResultType> extends Command<ResultType>
{
	var _configuration		: HTTPServiceConfiguration;
	var _request 			: Http;
	var _excludedParameters : Array<String>;
	var _timestamp 			: Float;
	var _parser				: IParser<ResultType>;

	public function new( ?url : String ) 
	{
		super();
		this._configuration = new HTTPServiceConfiguration( url );
	}
	
	public function execute() : HttpRequest<ResultType>
	{
		this._timestamp = Date.now().getTime ();
		
		if ( this._configuration == null || this._configuration.serviceUrl == null )
		{
			throw new NullPointerException( "_createRequest call failed. ServiceConfiguration.serviceUrl shouldn't be null @" + Stringifier.stringify( this ) );
		}
		
		this._createRequest();
		this._request.request( this._configuration.requestMethod == HTTPRequestMethod.POST );
		
		return this;
	}
	
	function _createRequest() : Void
	{
		this._request = new Http( this._configuration.serviceUrl );
		
		this._configuration.parameterFactory.setParameters( this._request, this._configuration.parameters, _excludedParameters );
		//this.timeoutDuration = this._configuration.serviceTimeout;
		
		#if js
			this._request.async 		= true;
		#end
		this._request.onData 		= this._onData;
		this._request.onError 		= this._onError;
		this._request.onStatus 		= this._onStatus;
		
		var requestHeaders : Array<HTTPRequestHeader> = this._configuration.requestHeaders;
		if ( requestHeaders != null )
		{
			for ( header in requestHeaders )
			{
				this._request.addHeader ( header.name, header.value );
			}
		}
	}
	
	public var url( get, null ) : String;
	public function get_url() : String
	{
		return this._configuration.serviceUrl;
	}
	
	public var method( get, null ) : HTTPRequestMethod;
	public function get_method() : HTTPRequestMethod
	{
		return this._configuration.requestMethod;
	}
	
	public var dataFormat( get, null ) : String;
	public function get_dataFormat() : String
	{
		return this._configuration.dataFormat;
	}
	
	public var timeout( get, null ) : UInt;
	public function get_timeout() : UInt
	{
		return this._configuration.serviceTimeout;
	}
	
	public function setParameters( parameters : HTTPServiceParameters ) : Void
	{
		this._configuration.parameters = parameters;
	}

	public function getParameters() : HTTPServiceParameters
	{
		return this._configuration.parameters;
	}

	public function addHeader( header : HTTPRequestHeader ) : Void
	{
		this._configuration.requestHeaders.push( header );
	}
	
	public function setParser( parser : IParser<ResultType> ) : Void
	{
		this._parser = parser;
	}
	
	//
	function _onData( result ) : Void
	{
		if (  this._parser != null )
		{
			this._complete( this._parser.parse( result ) );
		}
		else
		{
			this._complete( cast result );
		}
	}

	function _onError( message : String ) : Void
	{
		this._fail( message );
	}
	
	function _onStatus( status : Int ) : Void
	{
		trace( status );
	}
	
	/**
     * Memory handling
     */
    static var _POOL = new HashMap<Dynamic, Bool>();

    static function _isOrderDetained( order : Dynamic ) : Bool
    {
        return HttpRequest._POOL.containsKey( order );
    }

    static function _detainOrder( order : Dynamic ) : Void
    {
        HttpRequest._POOL.put( order, true );
    }

    static function _releaseOrder( order : Dynamic ) : Void
    {
        if ( HttpRequest._POOL.containsKey( order ) )
        {
            HttpRequest._POOL.remove( order );
        }
    }
}