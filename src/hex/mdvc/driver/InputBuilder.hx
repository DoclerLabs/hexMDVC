package hex.mdvc.driver;

import haxe.macro.Context;
import haxe.macro.Expr;
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
class InputBuilder
{
	public static inline var InputAnnotation = "Input";
	
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
		var inputVOList : Array<InputVO> = [];
		var implementedModules = [ for ( i in Context.getLocalClass().get().interfaces ) i.t.get() ];
		
		for ( f in fields )
		{
			switch( f.kind )
			{ 
				//TODO handle properties with virtual getters/setters
				case FVar( t, e ):
					
					var meta = f.meta.filter( function ( m ) { return m.name == InputBuilder.InputAnnotation; } );
					var isInput = meta.length > 0;
					if ( isInput ) 
					{
						var inputDefinition = InputBuilder._getInputDefinition( f );
						var inputType 		= MacroUtil.getClassType( inputDefinition.fullyQualifiedName );

						if ( inputType.module != Type.getClassName( IInput )  )
						{
							Context.error( "'" + f.name + "' property with '@" + InputBuilder.InputAnnotation 
												+ "' annotation is not typed '" + Type.getClassName( IInput ) 
												+ "<ConnecttionType>'", f.pos );
						}
						else
						{
							var className 				= inputDefinition.fullyQualifiedName;
							var typePath 				= MacroUtil.getTypePath( className );
							var complexType 			= TypeTools.toComplexType( Context.getType( className ) );

							if ( !InputBuilder._isImplementing( MacroUtil.getClassType( Context.getLocalClass().get().name ), implementedModules ) )
							{
								Context.error( "'" + Context.getLocalClass().get().name + "' does not implement '" 
													+ inputDefinition.connectionInterfaceName + "'\n It should with '@" 
													+ InputBuilder.InputAnnotation + "' annotation typed '"
													+ className + "<" + inputDefinition.connectionInterfaceName + ">'", f.pos );
							}
							
							var connectionType 			= Context.getType( inputDefinition.connectionInterfaceName );
							var connectionComplexType 	= TypeTools.toComplexType( connectionType );
							var inputTypePath 			= MacroUtil.getTypePath( Type.getClassName( Input ), [ TPType( connectionComplexType ) ] );
							inputVOList.push( { expr: { expr: MacroUtil.instantiate( inputTypePath, [macro this] ), pos: f.pos }, fieldName: f.name, pos: f.pos } );
						}
						
						f.meta = [];//TODO remove
					}
				
				case FFun( func ):
					
					if ( f.name == 'new' && inputVOList.length > 0 )
					{
						switch( func.expr.expr )
						{
							case EBlock( exprs ):
								for ( vo in inputVOList )
								{
									exprs.insert( 0, { expr: EBinop( OpAssign, _getFieldReference( vo.fieldName ), vo.expr ), pos: vo.pos } );
								}

							case _:
						}
					}
					
				case _:
			}
		}
		
		return fields;
	}
	
	static function _getFieldReference( fieldName : String )
	{
		var i = macro { this.$fieldName; };
		switch( i.expr ) 
		{ 
			case EBlock( exprs ): 
				return exprs[ 0 ]; 
				
			case _: return null; 
		};
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
				connectionInterfaceName = InputBuilder._getConnectionInterfaceName( p.params );

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
	
	static function _isImplementing( ct : ClassType, a : Array<ClassType> ) : Bool
	{
		for ( i in a )
		{
			if ( MacroUtil.implementsInterface( ct, i ) )
			{
				return true;
			}
		}
		
		return false;
	}
}

private typedef InputVO = 
{
	expr: { pos:Position, expr:ExprDef },
	fieldName: String,
	pos: Position
}