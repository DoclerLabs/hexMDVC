package hex.mdvc.control;

import hex.di.IDependencyInjector;
import hex.module.IModule;

/**
 * @author Francis Bourre
 */
interface ICommandTrigger
{
	var module     : IModule;
    var injector   : IDependencyInjector;
}