package hex.mdvtc.control;

import hex.di.IDependencyInjector;
import hex.di.IInjectorContainer;
import hex.module.IModule;

/**
 * ...
 * @author Francis Bourre
 */
#if !macro
@:autoBuild( hex.mdvtc.control.CommandTriggerBuilder.build() )
#end
class CommandTrigger implements ICommandTrigger implements IInjectorContainer
{
	@Inject
	public var module     		: IModule;
	
	@Inject
    public var injector   		: IDependencyInjector;
	
	function new() 
	{

	}
}