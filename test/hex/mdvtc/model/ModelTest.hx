package hex.mdvtc.model;

/**
 * ...
 * @author Francis Bourre
 */
class ModelTest
{
	@Test
    public function test() : Void
    {

    }
}

private class MockModel extends Model
{
    @Driver
    private var _driver : IMockValueDriver;

    public function new()
    {
        super();
    }

    public function changeValue( value : Int ) : Void
    {
        this._driver.onChangeValue( value );
    }
}

private interface IMockValueDriver
{
    function onChangeValue( value : Int ) : Void;
}