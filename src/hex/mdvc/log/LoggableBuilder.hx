package hex.mdvc.log;

import haxe.macro.Context;
import haxe.macro.Expr;
import hex.error.PrivateConstructorException;

/**
 * ...
 * @author Francis Bourre
 */
class LoggableBuilder
{
	public static inline var DebugAnnotation 	= "Debug";
	public static inline var InfoAnnotation 	= "Info";
	public static inline var WarnAnnotation 	= "Warn";
	public static inline var ErrorAnnotation 	= "Error";
	public static inline var FatalAnnotation 	= "Fatal";
	
	public static inline var LoggableAnnotation = "Log";

	
	/** @private */
    function new()
    {
        throw new PrivateConstructorException( "This class can't be instantiated." );
    }
	
	macro static public function build() : Array<Field> 
	{
		var fields = Context.getBuildFields();
		var className = Context.getLocalClass().get().module;
		var loggerAnnotations = [ DebugAnnotation, InfoAnnotation, WarnAnnotation, ErrorAnnotation, FatalAnnotation, LoggableAnnotation ];

		for ( f in fields )
		{
			switch( f.kind )
			{ 
				//TODO make unit tests
				case FFun( func ):
					
					var meta = f.meta.filter( function ( m ) { return loggerAnnotations.indexOf( m.name ) != -1; } );
					//var meta = f.meta.filter( function ( m ) { return m.name == LoggableBuilder.LoggableAnnotation; } );
					var isLoggable = meta.length > 0;
					if ( isLoggable ) 
					{
						//var methodList = LoggableBuilder._getMethodList( meta )[ 0 ];
						
						#if debug
						var expressions = [ macro @:mergeBlock {} ];
						var methArgs = [ for ( arg in func.args ) macro @:pos(f.pos) $i { arg.name } ];
						var debugArgs = [ macro @:pos(f.pos) $v { className + '::' + f.name } ].concat( methArgs );
						var methodName = meta[ 0 ].name.toLowerCase();
						
						var body = macro @:pos(f.pos) @:mergeBlock
						{
							#if debug
							logger.$methodName( [$a { debugArgs } ]/*, $v{posVO}*/ );
							#end
						};

						expressions.push( body );
						expressions.push( func.expr );
						func.expr = macro @:pos(f.pos) $b { expressions };
						#end
						
						f.meta = [];//TODO remove
					}
					
				case _:
			}
			
		}
		
		return fields;
	}
	
	static function _getMethodList( meta : Metadata ) : Array<Array<String>>
	{
		var a = [];
		for ( m in meta )
		{
			var params = m.params;
			for ( p in params )
			{
				var e = switch( p.expr )
				{
					case EConst( c ):
						switch( c )
						{
							case CIdent( s ):
								[ s.toString() ];
								
							case _: null;
						}
					
					case EField( e, field ):
						switch( e.expr ) 
						{ 
							case EConst( CIdent( s ) ):
								[ s.toString(), field ];
								
							case _: null;
						}
						
					case _: null;
				}
				
				a.push( e );
			}
		}
		return a;
	}
}