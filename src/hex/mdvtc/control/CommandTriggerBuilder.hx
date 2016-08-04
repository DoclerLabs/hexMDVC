package hex.mdvtc.control;

import haxe.macro.Context;
import haxe.macro.Expr.Field;
import hex.control.ICompletable;
import hex.control.Responder;
import hex.error.PrivateConstructorException;
import hex.module.IModule;
import hex.util.ClassUtil;
import hex.util.MacroUtil;

/**
 * ...
 * @author Francis Bourre
 */
@:final 
class CommandTriggerBuilder
{
	public static inline var MapAnnotation = "Map";
	
	static var modulePack  			= MacroUtil.getPack( Type.getClassName( IModule ) );
	static var ICompletableName 	= ClassUtil.getClassNameFromFullyQualifiedName( Type.getClassName( ICompletable ) );
	
	#if macro
	static var ICompletableClassType = MacroUtil.getClassType( Type.getClassName( ICompletable ) );
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
						if ( m.length > 1 )
						{
							Context.fatalError( "'" + Context.getLocalClass().get().name + "." + f.name + "' defines command mapping with '@" + CommandTriggerBuilder.MapAnnotation + "' more than once", f.pos );
						}
						
						var meta = m[ 0 ];
						f.meta.remove( meta );
						
						var commandName : String = null;
						
						for ( param in meta.params )
						{
							switch( param.expr )
							{
								case EConst( c ):
									switch ( c )
									{
										case CIdent( v ):
											commandName = hex.util.MacroUtil.getClassNameFromExpr( param );

										case _: 
									}
									
								case EField( e, field ):
									commandName = ( haxe.macro.ExprTools.toString( e ) + "." + field );

								case _: 
							}
						}
						
						if ( commandName == null )
						{
							Context.fatalError( "Invalid class name mapping passed to '" + Context.getLocalClass().get().name + "." + f.name + "' method.", f.pos );
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
											Context.error( "returned type '" + p.name 
												+ "' doesn't implement '"
												+ ICompletableClassType
												+ "' interface in method named '" 
												+ f.name + "'", f.pos );
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
						
						var typePath = MacroUtil.getTypePath( commandName, f.pos );
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