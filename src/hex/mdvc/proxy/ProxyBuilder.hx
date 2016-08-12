package hex.mdvc.proxy;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type.ClassField;
import haxe.macro.Type.ClassType;
import haxe.macro.TypeTools;
import hex.error.PrivateConstructorException;
import hex.util.MacroUtil;

using haxe.macro.Context;


/**
 * ...
 * @author Francis Bourre
 */
@:final 
class ProxyBuilder
{
	public static var ID : UInt = 0;
	public static inline var ProxyAnnotation = "Proxy";
	
	/** @private */
    function new()
    {
        throw new PrivateConstructorException( "This class can't be instantiated." );
    }
	
	//TODO make cache system
	//TODO check if property's type extends IInput
	macro static public function build() : Array<Field> 
	{
		var fields = Context.getBuildFields();
		
		for ( f in fields )
		{
			var meta = f.meta.filter( function ( m ) { return m.name == ProxyBuilder.ProxyAnnotation; } );
			var isProxy = meta.length > 0;
			if ( isProxy ) 
			{
				switch( f.kind )
				{ 
					//TODO handle properties with virtual getters/setters
					case FVar( t, e ):
						
						Context.fatalError( "'" + f.name + "' property is not public with read access only.\n Use 'public var " +
							f.name + " ( default, never )' with '@" + ProxyBuilder.ProxyAnnotation + "' annotation", f.pos );
					
					case FProp( get, set, t, e ):
						
						if ( get != "default" || set != "never" )
						{
							Context.fatalError( "'" + f.name + "' property is not public with read access only.\n Use 'public var " +
							f.name + " ( default, never )' with '@" + ProxyBuilder.ProxyAnnotation + "' annotation", f.pos );
						}
						
						//trace( meta[ 0 ].params );
						f.kind = _getKind( f, ProxyBuilder._getMethodList( meta ), get, set );
						f.meta = [];//TODO remove
						
					case _:
				}
			}
		}

        return fields;
	}
	
	static function _getMethodList( meta : Metadata ) : Array<String>
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
								s.toString();
								
							case _: null;
						}
						
					case _: null;
				}
				
				a.push( e );
			}
		}
		return a;
	}
	
	static function _getKind( f, methodList : Array<String>, ?get, ?set )
	{
		var proxyDefinition 	= ProxyBuilder._getProxyDefinition( f );
		var proxyType 			= MacroUtil.getClassType( proxyDefinition.fullyQualifiedName );


		var e 					= ProxyBuilder._buildClass( proxyDefinition, methodList );
		var className 	= e.pack.join( '.' ) + '.' + e.name;
		var typePath 	= MacroUtil.getTypePath( className );
		var complexType = TypeTools.toComplexType( Context.getType( className ) );
		
		return ( get == null && set == null ) ?
			FVar( complexType, { expr: MacroUtil.instantiate( typePath ), pos: f.pos } ):
			FProp( get, set, complexType, { expr: MacroUtil.instantiate( typePath ), pos: f.pos } );
		
		return f.kind;
	}
	
	static function _getProxyDefinition( f ) : { name: String, pack: Array<String>, fullyQualifiedName: String }
	{
		var name 					: String 			= "";
		var connectionDefinition 	: { name: String, pack: Array<String>, fullyQualifiedName: String } = null;
		
		//TODO DRY
		switch ( f.kind )
		{
			case FVar( TPath( p ), e ):

				ProxyBuilder._checkIProxyImplementation( f, p );
				connectionDefinition = ProxyBuilder._getModelDefinition( p.params );
				
				var t : haxe.macro.Type = Context.getType( p.pack.concat( [ p.name ] ).join( '.' ) );
				
				switch ( t )
				{
					case TInst( t, p ):
						var ct = t.get();
						name = ct.pack.concat( [ ct.name ] ).join( '.' );

					case _:
				}
			
			case FProp( get, set, TPath( p ), e ):
				
				ProxyBuilder._checkIProxyImplementation( f, p );
				connectionDefinition = ProxyBuilder._getModelDefinition( p.params );
				
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
		
		//TODO check double
		var tpName = connectionDefinition.fullyQualifiedName;
		if ( name != Type.getClassName( IProxy ) )
		{
			Context.fatalError( "'" + f.name + "' property with '@" + ProxyBuilder.ProxyAnnotation 
				+ "' annotation should be typed '" + Type.getClassName( IProxy ) + "<" + tpName 
				+ ">' instead of '" + name + "<" + tpName + ">'", f.pos );
		}
		
		return connectionDefinition;
	}
	
	static function _buildClass( modelClassName : { name: String, pack: Array<String>, fullyQualifiedName: String }, methodList : Array<String> ) : { name: String, pack: Array<String> }
	{
		//TODO make cache for generated classes
		ProxyBuilder.ID++;
		
		var className 			= "__" + ProxyBuilder.ProxyAnnotation + '_Class_For__' + modelClassName.name + ID;
		var type 				= Context.getType( modelClassName.fullyQualifiedName );
		var modelComplexType 	= TypeTools.toComplexType( type );
		
		//TODO implements IProxy
		var proxyClass = macro class $className
		{ 
			var _model : $modelComplexType;
			
			public function new() 
			{
				
			}
			
			public function proxy( model : $modelComplexType ) : Void
			{
				this._model = model;
			}
		};
		
		var newFields = proxyClass.fields;
		switch( type )
		{
			case TInst( _.get() => cls, params ):

				var fields : Array<ClassField> = cls.fields.get();

				for ( field in fields )
				{
					if ( methodList.indexOf( field.name ) != -1 )
					{
						//
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
									
									case TLazy( f ):
										
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
							//	trace( field.name, methArgs );
								var body = 
								macro 
								{
									return this._model.$methodName( $a{ methArgs } );
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
						//
					}
				}

				case _:
		}
		
		proxyClass.pack = modelClassName.pack.copy();
		
		/*switch( proxyClass.kind )
		{
			case TDClass( superClass, interfaces, isInterface ):
				interfaces.push( typePath );
				
			case _:
		}*/
		
		Context.defineType( proxyClass );
		
		return { name: proxyClass.name, pack: proxyClass.pack };
	}
	
	static function _checkIProxyImplementation( f, tp : TypePath ) : Void
	{
		var className = MacroUtil.getClassFullQualifiedName( tp );
		
		if ( className != Type.getClassName( IProxy )  )
		{
			Context.fatalError( "'" + f.name + "' property with '@" + ProxyBuilder.ProxyAnnotation 
								+ "' annotation is not typed '" + Type.getClassName( IProxy ) 
								+ "<ConnecttionType>'", f.pos );
		}
	}
	
	static function _getModelDefinition( params : Array<TypeParam> ) : { name: String, pack: Array<String>, fullyQualifiedName: String }
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
}
