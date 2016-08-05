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
	public static inline var OutputAnnotation = "Output";
	
	/** @private */
    function new()
    {
        throw new PrivateConstructorException( "This class can't be instantiated." );
    }
	
	//TODO make cache system
	macro static public function build() : Array<Field> 
	{
		var fields = Context.getBuildFields();
		
		for ( f in fields )
		{
			switch( f.kind )
			{ 
				//TODO handle properties with virtual getters/setters
				case FVar( t, e ):
					
					var isDispatcher = f.meta.filter( function ( m ) { return m.name== ModelBuilder.OutputAnnotation; } ).length > 0;
					if ( isDispatcher ) 
					{
						var outputDefinition 	= ModelBuilder._getOutputDefinition( f );
						var outputType 			= MacroUtil.getClassType( outputDefinition.fullyQualifiedName );
						
						if ( !outputType.isInterface )
						{
							Context.fatalError( "'<" + outputDefinition.fullyQualifiedName + 
								">' should be an interface. No class is allowed for property's type parameter with '@" 
									+ ModelBuilder.OutputAnnotation + "' annotation", f.pos );
						}
						else
						{
							var e 			= ModelBuilder._buildClass( outputDefinition );
							var className 	= e.pack.join( '.' ) + '.' + e.name;
							var typePath 	= MacroUtil.getTypePath( className );
							var complexType = TypeTools.toComplexType( Context.getType( className ) );
							
							f.kind 			= FProp( 'default', 'never', complexType, { expr: ModelBuilder._instantiate( typePath ), pos: f.pos } );
						}
					}
					
				case _:
			}
		}

        return fields;
    }
	
	static function _buildClass( interfaceName : { name: String, pack: Array<String>, fullyQualifiedName: String } ) : { name: String, pack: Array<String> }
	{
		var className 	= "__" + ModelBuilder.OutputAnnotation + '_Class_For__' + interfaceName.name;
		var typePath 	= MacroUtil.getTypePath( interfaceName.fullyQualifiedName );
		var type 		= Context.getType( interfaceName.fullyQualifiedName );
		var complexType = TypeTools.toComplexType( type );
		
		var params = [ TPType( complexType ) ];
		var connectorTypePath = MacroUtil.getTypePath( Type.getClassName( IOutput ), params );
		
		var dispatcherClass = macro class $className implements $connectorTypePath
		{ 
			var _inputs : Array<$complexType>;
	
			public function new() 
			{
				this._inputs = [];
			}

			public function connect( input : $complexType ) : Bool
			{
				if ( this._inputs.indexOf( input ) == -1 )
				{
					this._inputs.push( input );
					return true;
				}
				else
				{
					return false;
				}
			}

			public function disconnect( input : $complexType ) : Bool
			{
				var index : Int = this._inputs.indexOf( input );
				
				if ( index > -1 )
				{
					this._inputs.splice( index, 1 );
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
								for ( input in this._inputs ) input.$methodName( $a{ methArgs } );
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
		
		switch( dispatcherClass.kind )
		{
			case TDClass( a, params ):
				params.push( typePath );
				
			case _:
		}
		
		Context.defineType( dispatcherClass );
		
		return { name: dispatcherClass.name, pack: dispatcherClass.pack };
	}
	
	static function _getOutputDefinition( f ) : { name: String, pack: Array<String>, fullyQualifiedName: String }
	{
		var name 					: String 			= "";
		var connectionDefinition 	: { name: String, pack: Array<String>, fullyQualifiedName: String } = null;
		
		switch ( f.kind )
		{
			case FVar( TPath( p ), e ):
				
				connectionDefinition = ModelBuilder._getConnectionDefinition( p.params );
				
				var t : haxe.macro.Type = Context.getType( p.pack.concat( [ p.name ] ).join( '.' ) );
				
				switch ( t )
				{
					case TInst( t, p ):
						var ct = t.get();
						name = ct.pack.concat( [ ct.name ] ).join( '.' );

					case _:
				}

			case _:
		}
		
		var tpName = connectionDefinition.fullyQualifiedName;
		if ( name != Type.getClassName( IOutput ) )
		{
			Context.fatalError( "'" + f.name + "' property with '@" + ModelBuilder.OutputAnnotation 
				+ "' annotation should be typed '" + Type.getClassName( IOutput ) + "<" + tpName 
				+ ">' instead of '" + name + "<" + tpName + ">'", f.pos );
		}
		
		return connectionDefinition;
	}
	
	static function _getConnectionDefinition( params : Array<TypeParam> ) : { name: String, pack: Array<String>, fullyQualifiedName: String }
	{
		for ( param in params )
		{
			switch( param )
			{
				case TPType( tp ) :

					switch( tp )
					{
						case TPath( p ):
							var t = Context.getType( p.pack.concat( [ p.name ] ).join( '.' ) );
							switch ( t )
							{
								case TInst( t, p ):
									var ct = t.get();
									return { name: ct.name, pack: ct.pack, fullyQualifiedName: ct.pack.concat( [ ct.name ] ).join( '.' ) };
									
								case _:
							}
							
						case _:
					}
					
				case _:
				
			}
		}
		
		return null;
	}
	
	static inline function _instantiate( t : TypePath, ?args ) : ExprDef
	{
		return ENew( t, args == null ? [] : args );
	}
}