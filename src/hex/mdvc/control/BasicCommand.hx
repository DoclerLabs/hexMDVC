package hex.mdvc.control;

import hex.control.command.ICommand;
import hex.control.payload.ExecutionPayload;
import hex.di.IInjectorContainer;
import hex.log.ILogger;
import hex.mdvc.log.IsLoggable;

/**
 * ...
 * @author Francis Bourre
 */
class BasicCommand<ResultType> extends Command<ResultType> implements ICommand implements IInjectorContainer implements IsLoggable
{
	@Inject
	public var logger : ILogger;

	public function new() 
	{
		super();
	}
	
	override public function getLogger() : ILogger 
	{
		return this.logger;
	}
	
	public function getResult() : Array<Dynamic>
	{
		return null;
	}
	
	public function getReturnedExecutionPayload() : Array<ExecutionPayload>
	{
		return null;
	}
}