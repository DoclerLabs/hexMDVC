package hex.mdvc.control;

import hex.di.IDependencyInjector;
import hex.module.IModule;

/**
 * @author Francis Bourre
 */
#if !macro
@:autoBuild( hex.mdvc.control.CommandTriggerBuilder.build() )
#end
interface ICommandTrigger
{
	var module     : IModule;
    var injector   : IDependencyInjector;
}