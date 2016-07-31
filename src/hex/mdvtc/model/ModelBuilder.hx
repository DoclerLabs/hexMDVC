package hex.mdvtc.model;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type.ClassField;
import haxe.macro.TypeTools;
import hex.error.PrivateConstructorException;
import hex.util.MacroUtil;

using haxe.macro.Context;

/**
 * ...
 * @author Francis Bourre
 */
@:final 
class ModelBuilder
{
	public static inline var DispatcherAnnotation : String = "Dispatcher";
	
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
				case FVar( t, e ):
					
					var isDispatcher = f.meta.filter( function ( m ) { return m.name== ModelBuilder.DispatcherAnnotation; } ).length > 0;
					if ( isDispatcher ) 
					{
						var interfaceName 			= ModelBuilder.getClassName( f );
						var interfaceToImplement 	= MacroUtil.getClassType( interfaceName.fullyQualifiedName );
						
						if ( !interfaceToImplement.isInterface )
						{
							Context.error( "'" + f.name + "' property with '@" + ModelBuilder.DispatcherAnnotation + "' annotation should have interface type. No class is allowed.", f.pos );
						}
						else
						{
							var e 			= ModelBuilder.buildClass( interfaceName );
							var className 	= e.pack.join( '.' ) + '.' + e.name;
							var typePath 	= MacroUtil.getTypePath( className );
							var complexType = TypeTools.toComplexType( Context.getType( className ) );
							
							f.kind 			= FVar( complexType, { expr: ModelBuilder.instantiate( typePath ), pos: f.pos } );
						}
					}
					
				case _:
			}
		}

        return fields;
    }
	
	static function buildClass( interfaceName : { name: String, pack: Array<String>, fullyQualifiedName: String } ) 
	{
		var className 	= "__" + ModelBuilder.DispatcherAnnotation + '_Class_For__' + interfaceName.name;
		var typePath 	= MacroUtil.getTypePath( interfaceName.fullyQualifiedName );
		var type 		= Context.getType( interfaceName.fullyQualifiedName );
		var complexType = TypeTools.toComplexType( type );
		
		var dispatcherClass = macro class $className implements $typePath
		{ 
			var _listeners : Array<$complexType>;
	
			public function new() 
			{
				this._listeners = [];
			}

			public function addListener( listener : $complexType ) : Bool
			{
				if ( this._listeners.indexOf( listener ) == -1 )
				{
					this._listeners.push( listener );
					return true;
				}
				else
				{
					return false;
				}
			}

			public function removeListener( listener : $complexType ) : Bool
			{
				var index : Int = this._listeners.indexOf( listener );
				
				if ( index > -1 )
				{
					this._listeners.splice( index, 1 );
					return true;
				}
				else
				{
					return false;
				}
			}
		};

		var newFields = dispatcherClass.fields;
		switch( type )
		{
			case TInst( _.get() => cls, params ):

				var fields : Array<ClassField> = cls.fields.get();

				for ( field in fields )
				{
					switch( field.kind )
					{
						case FMethod( k ):
							
							var fieldType 					= field.type;
							var ret : ComplexType 			= null;
							var args : Array<FunctionArg> 	= [];
						
							switch( fieldType )
							{
								case TFun( a, r ):
									
									ret = r.toComplexType();

									if ( a.length > 0 )
									{
										args = a.map( function( arg )
										{
											return cast { name: arg.name, type: arg.t.toComplexType(), opt: arg.opt };
										} );
									}
								
								case _:
							}
							
							var newField : Field = 
							{
								meta: field.meta.get(),
								name: field.name,
								pos: field.pos,
								kind: null,
								access: [ APublic ]
							}

							var methodName  = field.name;
							var methArgs = [ for ( arg in args ) macro $i { arg.name } ];
							var body = 
							macro 
							{
								for ( listener in this._listeners ) listener.$methodName( $a{ methArgs } );
							};
							
							
							newField.kind = FFun( 
								{
									args: args,
									ret: ret,
									expr: body
								}
							);
							
							newFields.push( newField );
							
						case _:
					}
				}

				case _:
		}

		dispatcherClass.pack = interfaceName.pack.copy();
		Context.defineType( dispatcherClass );
		
		return { name: dispatcherClass.name, pack: dispatcherClass.pack };
	}
	
	static function getClassName( f ) : { name: String, pack: Array<String>, fullyQualifiedName: String }
	{
		var name : String 			= "";
		var pack : Array<String> 	= [];
		
		switch ( f.kind )
		{
			case FVar( TPath( p ), e ):
				
				var t : haxe.macro.Type = Context.getType( p.pack.concat( [ p.name ] ).join( '.' ) );
				
				switch ( t )
				{
					case TInst( t, p ):
						var ct = t.get();
						name = ct.name;
						pack = ct.pack;
						
					case _:
				}
			case _:
		}
		
		return { name : name, pack: pack, fullyQualifiedName: pack.concat( [ name ] ).join( '.' ) };
	}
	
	static public inline function instantiate( t : TypePath, ?args )
	{
		return ENew( t, args == null ? [] : args );
	}
}