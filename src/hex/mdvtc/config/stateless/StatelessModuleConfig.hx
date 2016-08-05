package hex.mdvtc.config.stateless;

import hex.config.stateless.IStatelessConfig;
import hex.di.IDependencyInjector;
import hex.di.IInjectorContainer;
import hex.error.VirtualMethodException;

/**
 * ...
 * @author Francis Bourre
 */
class StatelessModuleConfig implements IStatelessConfig implements IInjectorContainer
{
	@Inject
	public var injector : IDependencyInjector;
	
	public function new() 
	{
		
	}
	
	public function configure() : Void 
	{
		throw new VirtualMethodException( this + ".configure must be overridden" );
	}
	
	public function mapController<ControllerType>( controllerInterface : Class<ControllerType>, controllerClass : Class<ControllerType>,  name : String = "" ) : ControllerType
	{
		var instance : ControllerType;
		
		if ( !this.injector.hasDirectMapping( controllerInterface, name ) )
		{
			instance = this.injector.instantiateUnmapped( controllerClass );
			this.injector.mapToValue( controllerInterface, instance, name );
		}
		else
		{
			instance = this.injector.getInstance( controllerInterface, name );
		}

		return instance;
	}
	
	public function mapModel<ModelType>( modelInterface : Class<ModelType>, modelClass : Class<ModelType>,  name : String = "" ) : ModelType
	{
		var instance : ModelType;
		
		if ( !this.injector.hasDirectMapping( modelInterface, name ) )
		{
			instance = this.injector.instantiateUnmapped( modelClass );
			this.injector.mapToValue( modelInterface, instance, name );
		}
		else
		{
			instance = this.injector.getInstance( modelInterface, name );
		}

		return instance;
	}
	
	public function mapDriver<DriverType>( driverInterface : Class<DriverType>, driverClass : Class<DriverType>,  name : String = "" ) : DriverType
	{
		var instance : DriverType;
		
		if ( !this.injector.hasDirectMapping( driverInterface, name ) )
		{
			instance = this.injector.instantiateUnmapped( driverClass );
			this.injector.mapToValue( driverInterface, instance, name );
		}
		else
		{
			instance = this.injector.getInstance( driverInterface, name );
		}

		return instance;
	}
}