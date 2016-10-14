package hex.mdvc.module;

import hex.config.stateful.IStatefulConfig;
import hex.config.stateless.IStatelessConfig;
import hex.di.IBasicInjector;
import hex.di.IDependencyInjector;
import hex.di.Injector;
import hex.domain.ApplicationDomainDispatcher;
import hex.domain.Domain;
import hex.domain.DomainExpert;
import hex.error.IllegalStateException;
import hex.event.Dispatcher;
import hex.event.IDispatcher;
import hex.event.MessageType;
import hex.log.DomainLogger;
import hex.log.ILogger;
import hex.log.IsLoggable;
import hex.metadata.AnnotationProvider;
import hex.metadata.IAnnotationProvider;
import hex.module.IModule;
import hex.module.ModuleMessage;

/**
 * ...
 * @author Francis Bourre
 */
class Module implements IModule implements IsLoggable
{
	var _internalDispatcher 	: IDispatcher<{}>;
	var _domainDispatcher 		: IDispatcher<{}>;
	var _injector 				: Injector;
	var _annotationProvider 	: IAnnotationProvider;
	
	var logger 					: ILogger;

	public function new()
	{
		this._injector = new Injector();
		this._injector.mapToValue( IBasicInjector, this._injector );
		this._injector.mapToValue( IDependencyInjector, this._injector );
		
		this._domainDispatcher = ApplicationDomainDispatcher.getInstance().getDomainDispatcher( this.getDomain() );
		this._annotationProvider = AnnotationProvider.getAnnotationProvider( this.getDomain() );
		this._annotationProvider.registerInjector( this._injector );
		
		this._internalDispatcher = new Dispatcher<{}>();
		this._injector.mapToValue( IDispatcher, this._internalDispatcher );
		this._injector.mapToValue( IModule, this );
		
		this.logger = new DomainLogger( this.getDomain() );
		this._injector.mapToValue( ILogger, this.logger );
	}
			
	/**
	 * Initialize the module
	 */
	@:final 
	public function initialize() : Void
	{
		if ( !this.isInitialized )
		{
			this._onInitialisation();
			//this._checkRuntimeDependencies( this._getRuntimeDependencies() );
			this.isInitialized = true;
			this._fireInitialisationEvent();
		}
		else
		{
			throw new IllegalStateException( "initialize can't be called more than once. Check your code." );
		}
	}

	/**
	 * Accessor for module initialisation state
	 * @return <code>true</code> if the module is initialized
	 */
	@:final 
	@:isVar public var isInitialized( get, null ) : Bool;
	function get_isInitialized() : Bool
	{
		return this.isInitialized;
	}

	/**
	 * Accessor for module release state
	 * @return <code>true</code> if the module is released
	 */
	@:final 
	@:isVar public var isReleased( get, null ) : Bool;
	public function get_isReleased() : Bool
	{
		return this.isReleased;
	}

	/**
	 * Get module's domain
	 * @return Domain
	 */
	public function getDomain() : Domain
	{
		return DomainExpert.getInstance().getDomainFor( this );
	}

	/**
	 * Sends an event outside of the module
	 * @param	event
	 */
	public function dispatchPublicMessage( messageType : MessageType, ?data : Array<Dynamic> ) : Void
	{
		if ( this._domainDispatcher != null )
		{
			this._domainDispatcher.dispatch( messageType, data );
		}
		else
		{
			throw new IllegalStateException( "Domain dispatcher is null. Try to use 'Module.registerInternalDomain' before calling super constructor to fix the problem");
		}
	}
	
	/**
	 * Add callback for specific message type
	 */
	public function addHandler( messageType : MessageType, scope : Dynamic, callback : Dynamic ) : Void
	{
		if ( this._domainDispatcher != null )
		{
			this._domainDispatcher.addHandler( messageType, scope, callback );
		}
		else
		{
			throw new IllegalStateException( "Domain dispatcher is null. Try to use 'Module.registerInternalDomain' before calling super constructor to fix the problem");
		}
	}

	/**
	 * Remove callback for specific message type
	 */
	public function removeHandler( messageType : MessageType, scope : Dynamic, callback : Dynamic ) : Void
	{
		if ( this._domainDispatcher != null )
		{
			this._domainDispatcher.removeHandler( messageType, scope, callback );
		}
		else
		{
			throw new IllegalStateException( "Domain dispatcher is null. Try to use 'Module.registerInternalDomain' before calling super constructor to fix the problem");
		}
	}
	
	function _dispatchPrivateMessage( messageType : MessageType, ?data : Array<Dynamic> ) : Void
	{
		this._internalDispatcher.dispatch( messageType, data );
	}

	/**
	 * Release this module
	 */
	@:final 
	public function release() : Void
	{
		if ( !this.isReleased )
		{
			this.isReleased = true;
			this._onRelease();
			this._fireReleaseEvent();
			
			if ( this._domainDispatcher != null )
			{
				this._domainDispatcher.removeAllListeners();
			}
			
			this._internalDispatcher.removeAllListeners();
			DomainExpert.getInstance().releaseDomain( this );

			this._annotationProvider.unregisterInjector( this._injector );
			this._injector.destroyInstance( this );
			this._injector.teardown();
			
			this.logger = null;
		}
		else
		{
			throw new IllegalStateException( this + ".release can't be called more than once. Check your code." );
		}
	}
	
	public function getInjector() : IDependencyInjector
	{
		return this._injector;
	}
	
	public function getLogger() : ILogger
	{
		return this.logger;
	}
	
	/**
	 * Fire initialisation event
	 */
	@:final
	function _fireInitialisationEvent() : Void
	{
		if ( this.isInitialized )
		{
			this.dispatchPublicMessage( ModuleMessage.INITIALIZED, [ this ] );
		}
		else
		{
			throw new IllegalStateException( this + ".fireModuleInitialisationNote can't be called with previous initialize call." );
		}
	}

	/**
	 * Fire release event
	 */
	@:final
	function _fireReleaseEvent() : Void
	{
		if ( this.isReleased )
		{
			this.dispatchPublicMessage( ModuleMessage.RELEASED, [ this ] );
		}
		else
		{
			throw new IllegalStateException( this + ".fireModuleReleaseNote can't be called with previous release call." );
		}
	}
	
	/**
	 * Override and implement
	 */
	function _onInitialisation() : Void
	{

	}

	/**
	 * Override and implement
	 */
	function _onRelease() : Void
	{

	}
	
	/**
	 * Accessor for dependecy injector
	 * @return <code>IDependencyInjector</code> used by this module
	 */
	function _getDependencyInjector() : IDependencyInjector
	{
		return this._injector;
	}

	/**
	 * Add collection of module configuration classes that 
	 * need to be executed before initialisation's end
	 * @param	configurations
	 */
	function _addStatelessConfigClasses( configurations : Array<Class<IStatelessConfig>> ) : Void
	{
		for ( configurationClass in configurations )
		{
			var config : IStatelessConfig = this._injector.instantiateUnmapped( configurationClass );
			config.configure();
		}
	}
	
	/**
	 * Add collection of runtime configurations that 
	 * need to be executed before initialisation's end
	 * @param	configurations
	 */
	function _addStatefulConfigs( configurations : Array<IStatefulConfig> ) : Void
	{
		for ( configuration in configurations )
		{
			configuration.configure( this._injector, this._internalDispatcher, this );
		}
	}
	
	function _get<T>( type : Class<T> ) : T
	{
		return this._injector.getInstance( type );
	}
}