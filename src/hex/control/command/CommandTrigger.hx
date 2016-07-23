package hex.control.command;

import hex.di.IDependencyInjector;
import hex.di.IInjectorContainer;
import hex.module.IModule;

/**
 * ...
 * @author Francis Bourre
 */
#if !macro
@:autoBuild( hex.control.command.CommandTriggerBuilder.build() )
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