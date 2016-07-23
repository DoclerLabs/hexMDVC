package hex.control.command;

import haxe.macro.Context;
import haxe.macro.Expr.Field;
import hex.annotation.MethodAnnotationData;
import hex.control.Responder;
import hex.module.IModule;
import hex.util.MacroUtil;

/**
 * ...
 * @author Francis Bourre
 */
class CommandTriggerBuilder
{
	public static inline var ClassAnnotation : String = "Class";
	
	function new()
	{
		
	}
	
	macro static public function build() : Array<Field> 
	{
		var modulePack  = MacroUtil.getPack( Type.getClassName( IModule ) );
		var fields      = Context.getBuildFields();
		
		//parse annotations
		fields = hex.annotation.AnnotationReader.parseMetadata( Type.getClassName( ICommandTrigger ), [ ClassAnnotation ], true );
		
		//get data result
		var data = hex.annotation.AnnotationReader._static_classes[ hex.annotation.AnnotationReader._static_classes.length - 1 ];
		
		//Create command class map
		var tMap : Map<String, String> = new Map();
		
		//Create responder
		var responderTypePath = MacroUtil.getTypePath( Type.getClassName( hex.control.Responder ) );

		for ( method in data.methods )
		{
			tMap.set( method.methodName, getAnnotation( method, ClassAnnotation ) );
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
							var typePath = MacroUtil.getTypePath( commandClassName );
							var args = [ for (arg in func.args) macro $i { arg.name } ];
							
							switch ( func.ret )
							{
								case TPath( p ): 
								default: null;
							}

							func.expr = macro 
							{
								var action = new $typePath();
								this.injector.injectInto( action );
								action.setOwner( this.injector.getInstance( $p { modulePack } ) );
	
								Reflect.callMethod( action, Reflect.field( action, action.executeMethodName ), $a { args } );
								return new $responderTypePath( action );
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