package hex.control;

import hex.di.IDependencyInjector;
import hex.di.IInjectorContainer;
import hex.module.IModule;

/**
 * @author Francis Bourre
 */
interface ICommandTrigger
{
	var module     : IModule;
    var injector   : IDependencyInjector;
}