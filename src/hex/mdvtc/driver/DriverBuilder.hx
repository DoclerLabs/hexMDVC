package hex.mdvtc.driver;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.TypeTools;
import hex.error.PrivateConstructorException;
import hex.util.MacroUtil;

using haxe.macro.Context;

/**
 * ...
 * @author Francis Bourre
 */
class DriverBuilder
{
	public static inline var InputAnnotation = "Input";
	static var _thisInput = _getThisInput();
	
	static function _getThisInput()
	{
		var i = macro { this.input; };
		switch( i.expr ) 
		{ 
			case EBlock( exprs ): 
				return exprs[ 0 ]; 
				
			case _: return null; 
		};
	}
	
	/** @private */
    function new()
    {
        throw new PrivateConstructorException( "This class can't be instantiated." );
    }
	
	//TODO make cache system
	macro static public function build() : Array<Field> 
	{
		var fields = Context.getBuildFields();
		var inputVOList : Array<InputVO> = [];
		
		for ( f in fields )
		{
			switch( f.kind )
			{ 
				//TODO handle properties with virtual getters/setters
				case FVar( t, e ):
					
					var isInput = f.meta.filter( function ( m ) { return m.name == DriverBuilder.InputAnnotation; } ).length > 0;
					if ( isInput ) 
					{
						var inputDefinition = DriverBuilder._getInputDefinition( f );
						var inputType 		= MacroUtil.getClassType( inputDefinition.fullyQualifiedName );
						
						if ( !inputType.isInterface )
						{
							Context.error( "'" + f.name + "' property with '@" + DriverBuilder.InputAnnotation + "' annotation should have interface type. No class is allowed.", f.pos );
						}
						else
						{
							var className 				= inputDefinition.fullyQualifiedName;
							var typePath 				= MacroUtil.getTypePath( className );
							var complexType 			= TypeTools.toComplexType( Context.getType( className ) );

							var connectionType 			= Context.getType( inputDefinition.connectionInterfaceName );
							var connectionComplexType 	= TypeTools.toComplexType( connectionType );
							var inputTypePath 			= MacroUtil.getTypePath( Type.getClassName( Input ), [ TPType( connectionComplexType ) ] );
	
							inputVOList.push( { expr: { expr: DriverBuilder._instantiate( inputTypePath, [macro this] ), pos: f.pos }, propertyName: f.name, pos: f.pos } );
						}
					}
				
				case FFun( func ):
					
					if ( f.name == 'new' && inputVOList.length > 0 )
					{
						switch( func.expr.expr )
						{
							case EBlock( exprs ):
								for ( vo in inputVOList )
								{
									exprs.insert( 0, { expr: EBinop( OpAssign, _thisInput, vo.expr ), pos: vo.pos } );
								}

							case _:
						}
					}
					
				case _:
			}
		}
		
		return fields;
	}
	
	static function _getInputDefinition( f ) : { name: String, pack: Array<String>, fullyQualifiedName: String, connectionInterfaceName: String, ct:ComplexType }
	{
		var name 					: String 			= "";
		var pack 					: Array<String> 	= [];
		var connectionInterfaceName : String			= "";
		var ct 						: ComplexType		= null;
		
		switch ( f.kind )
		{
			case FVar( TPath( p ), e ):

				ct = TPath( p );
				connectionInterfaceName = DriverBuilder._getConnectionInterfaceName( p.params );

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
		
		return { name: name, pack: pack, fullyQualifiedName: pack.concat( [ name ] ).join( '.' ), connectionInterfaceName: connectionInterfaceName, ct: ct };
	}
	
	static function _getConnectionInterfaceName( params : Array<TypeParam> ) : String
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
									return ct.pack.concat( [ ct.name ] ).join( '.' );
									
								case _:
							}
							
						case _:
					}
					
				case _:
				
			}
		}
		
		return null;
	}
	
	static inline function _instantiate( t : TypePath, ?args )
	{
		return ENew( t, args == null ? [] : args );
	}
}

private typedef InputVO = 
{
	expr: { pos:Position, expr:ExprDef },
	propertyName: String,
	pos: Position
}