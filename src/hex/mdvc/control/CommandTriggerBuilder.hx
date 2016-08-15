package hex.mdvc.control;

import haxe.macro.Expr.Position;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr.Field;
import hex.control.ICompletable;
import hex.control.Responder;
import hex.error.PrivateConstructorException;
import hex.module.IModule;
import hex.util.ClassUtil;
import hex.util.MacroUtil;
#end

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
	static var ICompletableName 		= ClassUtil.getClassNameFromFullyQualifiedName( Type.getClassName( ICompletable ) );
	static var CommandClassType 		= MacroUtil.getClassType( Type.getClassName( Command ) );
	static var ICompletableClassType 	= MacroUtil.getClassType( Type.getClassName( ICompletable ) );
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
							Context.error(  	"'" + f.name + "' method defines more than one command mapping (with '@" + 
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
												Context.error( "Invalid class reference mapped (with '@" + CommandTriggerBuilder.MapAnnotation + 
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
							Context.error( "Invalid class reference mapped (with '@" + CommandTriggerBuilder.MapAnnotation + 
								"' annotation) to '" + f.name + "' method in '" + className + "' class", command.pos );
						}
						

						var typePath = MacroUtil.getTypePath( command.name, command.pos );

						if ( !MacroUtil.isSubClassOf( MacroUtil.getClassType( command.name ), CommandClassType ) )
						{
							Context.error( "'" + className + "' is mapped as a command class (with '@" + CommandTriggerBuilder.MapAnnotation + 
								"' annotation), but it doesn't extend '" + CommandClassType.module + "' class", command.pos );
						}

						//
						var argumentDatas : Array<{name:String, type:String}> = [];
						for ( arg in func.args )
						{
							switch ( arg.type )
							{
								case TPath( p ):
									
									var t : haxe.macro.Type = Context.getType( p.pack.concat( [ p.name ] ).join( '.' ) );
									var argumentType : String = "";
									
									switch ( t )
									{
										case TInst( t, p ):
											var ct = t.get();
											argumentType = ct.pack.concat( [ct.name] ).join( '.' );
											
										case TAbstract( t, params ):
											argumentType = t.toString();
											
										case TDynamic( t ):
											argumentType = "Dynamic";
											
										default:
									}

									argumentDatas.push( { name: arg.name, type: argumentType } );

								default:
							}
						}

						var responderTypePath = switch ( func.ret )
						{
							case TPath( p ): 
									
									if ( p.name != ICompletableName )
									{
										var returnType = Context.getType( p.name );
										
										if ( !MacroUtil.implementsInterface( MacroUtil.getClassType( p.name ), ICompletableClassType ) )
										{
											Context.error( "returned type '" + p.name + "' doesn't implement '" + ICompletableClassType.module + "' interface", f.pos );
										}
										else
										{
											switch( returnType ) 
											{ 
												case TInst( t, s ): 
													MacroUtil.getTypePath( '' + t );
													
												default: 
													MacroUtil.getTypePath( Type.getClassName( Responder ) );
											}
										}
									}
									else
									{
										MacroUtil.getTypePath( Type.getClassName( Responder ) );
									}
									
							default: null;
						}
						
						var args = [ for ( arg in argumentDatas ) macro $i { arg.name } ];
						
						func.expr = macro 
						{
							var command = new $typePath();
							this.injector.injectInto( command );
							command.setOwner( this.injector.getInstance( $p { modulePack } ) );
							Reflect.callMethod( command, Reflect.field( command, command.executeMethodName ), $a { args } );
							return new $responderTypePath( command );
						};
					}
				}
				
				case _:
			}
		}
		
		return fields;
	}
}