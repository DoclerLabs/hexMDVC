package hex.mdvc.control;

import haxe.macro.Context;
import haxe.macro.Expr.Access;
import haxe.macro.Expr.Field;
import haxe.macro.Expr.Position;
import hex.control.async.Expect;
import hex.error.PrivateConstructorException;
import hex.module.IModule;
import hex.util.MacroUtil;

/**
 * ...
 * @author Francis Bourre
 */
@:final 
class CommandTriggerBuilder
{
	public static inline var MapAnnotation = "Map";
	
	#if macro
	static var modulePack  				= MacroUtil.getPack( Type.getClassName( IModule ) );
	static var CommandClassType 		= MacroUtil.getClassType( Type.getClassName( Command ) );
	static var IAsyncCallbackType 		= MacroUtil.getClassType( Type.getClassName( Expect ) );
	#end
	
	/** @private */
    function new()
    {
        throw new PrivateConstructorException( "This class can't be instantiated." );
    }
	
	macro static public function build() : Array<Field> 
	{
		var fields = Context.getBuildFields();
		
		for ( f in fields )
		{
			switch( f.kind )
			{ 
				case FFun( func ) :
				{
					var m = f.meta.filter( function ( m ) { return m.name == CommandTriggerBuilder.MapAnnotation; } );
					var isMapped = m.length > 0;
					
					if ( isMapped )
					{
						var className = Context.getLocalModule();
						
						if ( m.length > 1 )
						{
							Context.error(  "'" + f.name + "' method defines more than one command mapping (with '@" + 
											CommandTriggerBuilder.MapAnnotation + "' annotation) in '" + className + "' class", m[ 1 ].pos );
						}
						
						var meta = m[ 0 ];
						f.meta.remove( meta );
						
						var command : { name: String, pos: Position } = { name: null, pos: meta.pos };
						
						for ( param in meta.params )
						{
							switch( param.expr )
							{
								case EConst( c ):
									switch ( c )
									{
										case CIdent( v ):
											try
											{
												command.name = hex.util.MacroUtil.getClassNameFromExpr( param );
											}
											catch ( e : Dynamic )
											{
												Context.error( "Invalid class name mapped (with '@" + CommandTriggerBuilder.MapAnnotation + 
													"' annotation) to '" + f.name + "' method in '" + className + "' class", param.pos );
											}
											
											command.pos = param.pos;

										case _: 
									}
									
								case EField( e, field ):
									command.name = ( haxe.macro.ExprTools.toString( e ) + "." + field );
									command.pos = param.pos;

								case _: 
							}
						}
						
						if ( command.name == null )
						{
							Context.error( "Invalid class name mapped (with '@" + CommandTriggerBuilder.MapAnnotation + 
								"' annotation) to '" + f.name + "' method in '" + className + "' class", command.pos );
						}
						

						var typePath = MacroUtil.getTypePath( command.name, command.pos );

						if ( !MacroUtil.isSubClassOf( MacroUtil.getClassType( command.name ), CommandClassType ) )
						{
							Context.error( "'" + className + "' is mapped as a command class (with '@" + CommandTriggerBuilder.MapAnnotation + 
								"' annotation), but it doesn't extend '" + CommandClassType.module + "' class", command.pos );
						}


						var args = [ for ( arg in func.args )  macro $i { arg.name } ];
		
						func.expr = macro 
						{
							var command = new $typePath( $a { args } );
							this.injector.injectInto( command );
							command.setOwner( this.injector.getInstance( $p { modulePack } ) );
							command.execute();
							return command;
						};
						
					}
				}
				
				case _:
			}
		}
		
		fields.push({ 
				kind: FVar(TPath( { name: "IModule", pack:  [ "hex", "module" ], params: [] } ), null ), 
				meta: [ { name: "Inject", params: [], pos: Context.currentPos() }, { name: ":noCompletion", params: [], pos: Context.currentPos() } ], 
				name: "module", 
				access: [ Access.APublic ],
				pos: Context.currentPos()
			});
			
		fields.push({ 
				kind: FVar(TPath( { name: "IDependencyInjector", pack:  [ "hex", "di" ], params: [] } ), null ), 
				meta: [ { name: "Inject", params: [], pos: Context.currentPos() }, { name: ":noCompletion", params: [], pos: Context.currentPos() } ], 
				name: "injector", 
				access: [ Access.APublic ],
				pos: Context.currentPos()
			});
			
		return fields;
	}
}