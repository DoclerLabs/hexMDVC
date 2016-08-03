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
	
	public function mapController<ControllerType>( controllerInterface : Class<ControllerType>, controllerClass : Class<ControllerType>,  name : String = "" ) : Void
	{
		var instance : Dynamic = this.injector.instantiateUnmapped( controllerClass );
		this.injector.mapToValue( controllerInterface, instance, name );
	}
	
	public function mapModel<ModelType>( modelInterface : Class<ModelType>, modelClass : Class<ModelType>,  name : String = "" ) : Void
	{
		var instance : Dynamic = this.injector.instantiateUnmapped( modelClass );
		this.injector.mapToValue( modelInterface, instance, name );
		this.injector.mapToValue( Type.resolveClass( Type.getClassName( modelInterface ) + "RO" ), instance );
	}
	
	public function mapDriver<DriverType>( driverInterface : Class<DriverType>, driverClass : Class<DriverType>,  name : String = "" ) : Void
	{
		var instance : Dynamic = this.injector.instantiateUnmapped( driverClass );
		this.injector.mapToValue( driverInterface, instance, name );
	}
}