package hex.mdvtc.control;

import haxe.macro.Context;
import haxe.macro.Expr.Field;
import hex.annotation.MethodAnnotationData;
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
	public static inline var MapAnnotation : String = "Map";
	
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
		
		//parse annotations
		fields = hex.annotation.AnnotationReader.parseMetadata( Context.makeExpr( ICommandTrigger, Context.currentPos() ), [ CommandTriggerBuilder.MapAnnotation ], true );
		
		//get data result
		var data = hex.annotation.AnnotationReader._static_classes[ hex.annotation.AnnotationReader._static_classes.length - 1 ];
		
		//Create command class map
		var tMap : Map<String, String> = new Map();
		for ( method in data.methods )
		{
			tMap.set( method.methodName, CommandTriggerBuilder.getAnnotation( method, MapAnnotation ) );
		}

		for ( field in fields ) 
		{
			switch ( field.kind ) 
			{
				case FFun( func ) :
				
					var methodName  = field.name;
					if ( tMap.exists( methodName ) )
					{
						var commandClassName : String = tMap.get( methodName );
	
						if ( commandClassName != null )
						{
							var typePath = MacroUtil.getTypePath( commandClassName, field.pos );
							var args = [ for ( arg in func.args ) macro $i { arg.name } ];
							
							//get responder TypePath
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
													+ methodName + "'", field.pos );
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
					
				default : 
			}
		}

		return fields;
	}

	static function getAnnotation( method : MethodAnnotationData, annotationName : String )
	{
		var meta = method.annotationDatas.filter( function ( v ) { return v.annotationName == annotationName; } );
		if ( meta.length > 0 )
		{
			return meta[ 0 ].annotationKeys[ 0 ];
		}
		else
		{
			return null;
		}
	}
}