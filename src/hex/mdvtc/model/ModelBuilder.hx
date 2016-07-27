package hex.mdvtc.model;

import haxe.macro.Context;
import haxe.macro.Expr.Field;
import hex.error.PrivateConstructorException;
import hex.util.ClassUtil;
import hex.util.MacroUtil;

/**
 * ...
 * @author Francis Bourre
 */
@:final 
class ModelBuilder
{
	public static inline var DriverAnnotation : String = "Driver";
	
	/** @private */
    function new()
    {
        throw new PrivateConstructorException( "This class can't be instantiated." );
    }
	
	macro static public function build() : Array<Field> 
	{
		var fields = Context.getBuildFields();
        
        //parse annotations
		fields = hex.annotation.AnnotationReader.parseMetadata( Context.makeExpr( Model, Context.currentPos() ), [ ModelBuilder.DriverAnnotation ], true );

        //get data result
		var data = hex.annotation.AnnotationReader._static_classes[ hex.annotation.AnnotationReader._static_classes.length - 1 ];

        return fields;
    }
}