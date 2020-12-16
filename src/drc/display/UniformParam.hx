package drc.display;

import drc.display.UniformFormat;
import haxe.ds.Either;
import drc.utils.OneOf;

class UniformParam<T> {

    public var index(default, null):Int;

    public var type(default, null):UniformFormat;
    
	public var value(get, set):Array<T>;

    // ** Privates.

    private var __value:Array<T>;

    public function new(values:Array<T>, index:Int, type:UniformFormat) {

        __value = values;

        this.index = index;

        this.type = type;
    }

    public function foo(value:Array<T>, index:Int, type:UniformFormat) {

        this.value = value;

        this.index = index;

        this.type = type;
    }

    public function getPackedValue():Array<T> {
        
        return __value;
    }

    // ** Getters and setters.

    private function get_value():Array<T> {
        
        return __value;
    }

    private function set_value(value:Array<T>):Array<T> {
        
        __value = value;

        return value;
    }
}