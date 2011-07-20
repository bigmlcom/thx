/**
 * ...
 * @author Franco Ponticelli
 */
import thx.culture.Culture;
import thx.culture.FormatParams;

class Arrays
{
	/**
	 * push the value into the array and return the array itself only if the condition
	 * evaluates to true.
	 */
	public static function addIf<T>(arr : Array<T>, ?condition : Bool, value : Null<T>) : Array<T>
	{
		if (null != condition)
		{
			if(condition)
				arr.push(value);
		} else if (null != value)
			arr.push(value);
		return arr;
	}
	
	/**
	 * push the value into the array and return the array itself
	 */
	inline public static function add<T>(arr : Array<T>, value : T) : Array<T>
	{
		arr.push(value);
		return arr;
	}
	
	/**
	 * removes the value from the array and return the array itself
	 */
	inline public static function delete<T>(arr : Array<T>, value : T) : Array<T>
	{
		arr.remove(value);
		return arr;
	}
	
	/**
	 * creates a new array filtered by the 'f' function
	 */
	public static function filter<T>(arr : Array<T>, f : T -> Bool) : Array<T>
	{
		var result = [];
		for (i in arr)
			if (f(i))
				result.push(i);
		return result;
	}

	public static function min<T>(arr : Array<T>, ?f : T -> Float) : Null<T>
	{
		if (arr.length == 0)
			return null;
		if (null == f) {
			var a = arr[0], p = 0;
			for(i in 1...arr.length) if(Reflect.compare(a, arr[i]) > 0) a = arr[p = i];
			return arr[p];
		} else {
			var a = f(arr[0]), p = 0, b;
			for(i in 1...arr.length) if(a > (b = f(arr[i]))) { a = b; p = i; }
			return arr[p];
		}
	}
	
	public static function floatMin<T>(arr : Array<T>, f : T -> Float) : Float
	{
		if (arr.length == 0)
			return Math.NaN;
		var a = f(arr[0]), b;
		for(i in 1...arr.length) if(a > (b = f(arr[i]))) { a = b; }
		return a;
	}
	
	public static function max<T>(arr : Array<T>, ?f : T -> Float) : Null<T>
	{
		if (arr.length == 0)
			return null;
		if (null == f) {
			var a = arr[0], p = 0;
			for(i in 1...arr.length) if(Reflect.compare(a, arr[i]) < 0) a = arr[p = i];
			return arr[p];
		} else {
			var a = f(arr[0]), p = 0, b;
			for(i in 1...arr.length) if(a < (b = f(arr[i]))) { a = b; p = i; }
			return arr[p];
		}
	}
	
	public static function floatMax<T>(arr : Array<T>, f : T -> Float) : Float
	{
		if (arr.length == 0)
			return Math.NaN;
		var a = f(arr[0]), b;
		for(i in 1...arr.length) if(a < (b = f(arr[i]))) { a = b; }
		return a;
	}
	
	public static function flatten<T>(arr : Array<Array<T>>) : Array<T>
	{
		var r = [];
		for (v in arr)
			r = r.concat(v);
		return r;
	}
	
	inline public static function map<TIn,TOut>(arr : Array<TIn>, f : TIn -> Int -> TOut) : Array<TOut>
	{
		#if js
		return untyped arr.map(f);
		#else
		return Iterators.map(arr.iterator(), f);
		#end
	}
	
	inline public static function reduce<TIn,TOut>(arr : Array<TIn>, f : TOut -> TIn -> Int -> TOut, initialValue : TOut) : TOut
	{
	//	#if js
	//	return untyped arr.reduce(f, initialValue);
	//	#else
		return Iterators.reduce(arr.iterator(), f, initialValue);
	//	#end
	}
	
	inline public static function order<T>(arr : Array<T>, ?f : T -> T -> Int)
	{
		arr.sort(null == f ? Dynamics.compare : f);
		return arr;
	}
	
	public static function orderMultiple<T>(arr : Array<T>, ?f : T -> T -> Int, rest : Array<Array<Dynamic>>)
	{
		var swap = true,
			t : Dynamic;
		rest.remove(arr); // prevents infinite loop if hte arr is passed twice
		while (swap)
		{
			swap = false;
			for (i in 0...arr.length - 1)
			{
				if (f(arr[i], arr[i + 1]) > 0)
				{
					swap = true;

					t = arr[i];
					arr[i] = arr[i + 1];
					arr[i + 1] = t;

					for (a in rest)
					{
						t = a[i];
						a[i] = a[i+1];
						a[i+1] = t;
					}
				}
			}
		}
	}
	
	public static function split<T>(arr : Array<T>, ?f : T -> Int -> Bool) : Array<Array<T>>
	{
		if (null == f) f = function(v, _) return v == null;
		var arrays = [],
			i = -1,
			values = [],
			value;
		for(i in 0...arr.length)
		{
			if (f(value = arr[i], i))
				values = [];
			else {
				if (values.length == 0) arrays.push(values);
				values.push(value);
			}
		}
		return arrays;
	}
	
	public static function exists<T>(arr : Array<T>, ?value : T, ?f : T -> Bool)
	{
		if (null != f)
		{
			for (v in arr)
				if (f(v))
					return true;
		} else {
			for (v in arr)
				if (v == value)
					return true;
		}
		return false;
	}
	
	public static function format(v : Array<Dynamic>, ?param : String, ?params : Array<String>, ?culture : Culture)
	{
		params = FormatParams.params(param, params, 'J');
		var format = params.shift();
		switch(format)
		{
			case 'J':
				if (v.length == 0)
				{
					var empty = null == params[1] ? '[]' : params[1];
					return empty;
				}
				
				var sep = null == params[2] ? ', ' : params[2];
				var max : Null<Int> = params[3] == null ? null : ('' == params[3] ? null : Std.parseInt(params[3]));
				if (null != max && max < v.length)
				{
					var elipsis = null == params[4] ? ' ...' : params[4];
					return Arrays.map(v.copy().splice(0, max), function(d, i) return Dynamics.format(d, params[0], culture)).join(sep) + elipsis;
				} else
					return Arrays.map(v, function(d, i) return Dynamics.format(d, params[0], culture)).join(sep);
			case 'C':
				return Ints.format(v.length, 'I', [], culture);
			default:
				throw "Unsupported array format: " + format;
		}
	}
	
	public static function formatf(?param : String, ?params : Array<String>, ?culture : Culture)
	{
		params = FormatParams.params(param, params, 'J');
		var format = params.shift();
		switch(format)
		{
			case 'J':
				return function(v : Array<Dynamic>)
				{
					if (v.length == 0)
					{
						var empty = null == params[1] ? '[]' : params[1];
						return empty;
					}
					
					var sep = null == params[2] ? ', ' : params[2];
					var max : Null<Int> = params[3] == null ? null : ('' == params[3] ? null : Std.parseInt(params[3]));
					if (null != max && max < v.length)
					{
						var elipsis = null == params[4] ? ' ...' : params[4];
						return Arrays.map(v.copy().splice(0, max), function(d, i) return Dynamics.format(d, params[0], culture)).join(sep) + elipsis;
					} else
						return Arrays.map(v, function(d, i) return Dynamics.format(d, params[0], culture)).join(sep);
				}
			case 'C':
				var f = Ints.formatf('I', [], culture);
				return function(v) return f(v.length);
			default:
				throw "Unsupported array format: " + format;
		}
	}
	
	public static function interpolate(v : Float, a : Array<Float>, b : Array<Float>, ?equation : Float -> Float) : Array<Float>
	{
		return interpolatef(a, b, equation)(v);
	}
	
	public static function interpolatef(a : Array<Float>, b : Array<Float>, ?equation : Float -> Float)
	{
		var functions = [],
			i = 0,
			min = Ints.min(a.length, b.length);
			
		while (i < min)
		{
			if (a[i] == b[i])
			{
				var v = b[i];
				functions.push(function(_) return v);
			} else
				functions.push(Floats.interpolatef(a[i], b[i], equation));
			i++;
		}
		while (i < b.length)
		{
			var v = b[i];
			functions.push(function(_) return v);
			i++;
		}
		return function(t) return Arrays.map(functions, function(f, _) return f(t));
	}
	
	public static function interpolateStrings(v : Float, a : Array<String>, b : Array<String>, ?equation : Float -> Float) : Array<String>
	{
		return interpolateStringsf(a, b, equation)(v);
	}
	
	public static function interpolateStringsf(a : Array<String>, b : Array<String>, ?equation : Float -> Float)
	{
		var functions = [],
			i = 0,
			min = Ints.min(a.length, b.length);
			
		while (i < min)
		{
			if (a[i] == b[i])
			{
				var v = b[i];
				functions.push(function(_) return v);
			} else
				functions.push(Strings.interpolatef(a[i], b[i], equation));
			i++;
		}
		while (i < b.length)
		{
			var v = b[i];
			functions.push(function(_) return v);
			i++;
		}
		return function(t) return Arrays.map(functions, function(f, _) return f(t));
	}
	
	public static function interpolateInts(v : Float, a : Array<Int>, b : Array<Int>, ?equation : Float -> Float) : Array<Int>
	{
		return interpolateIntsf(a, b, equation)(v);
	}
	
	public static function interpolateIntsf(a : Array<Int>, b : Array<Int>, ?equation : Float -> Float)
	{
		var functions = [],
			i = 0,
			min = Ints.min(a.length, b.length);
			
		while (i < min)
		{
			if (a[i] == b[i])
			{
				var v = b[i];
				functions.push(function(_) return v);
			} else
				functions.push(Ints.interpolatef(a[i], b[i], equation));
			i++;
		}
		while (i < b.length)
		{
			var v = b[i];
			functions.push(function(_) return v);
			i++;
		}
		return function(t) return Arrays.map(functions, function(f, _) return f(t));
	}
	
	#if js inline #end public static function indexOf<T>(arr : Array<T>, el : T)
	{
#if js
		return untyped arr.indexOf(el);
#else
		var len = arr.length;
		for (i in 0...len)
			if (arr[i] == el)
				return  i;
		return -1;
#end
	}
	
	#if js inline #end public static function every<T>(arr : Array<T>, f : T -> Int -> Bool) : Bool
	{
#if js
		return untyped arr.every(f);
#else
		for (i in 0...arr.length)
			if (!f(arr[i], i))
				return false;
		return true;
#end
	}
	
	#if js inline #end public static function each<T>(arr : Array<T>, f : T -> Int -> Void) : Void
	{
#if js
		untyped arr.forEach(f);
#else
		for (i in 0...arr.length)
			f(arr[i], i);
#end
	}
	
	inline public static function any<T>(arr : Array<T>, f : T -> Bool) : Bool
	{
		return Iterators.any(arr.iterator(), f);
	}
	
	inline public static function all<T>(arr : Array<T>, f : T -> Bool) : Bool
	{
		return Iterators.all(arr.iterator(), f);
	}
	
	public static function random<T>(arr : Array<T>) : T
	{
		return arr[Std.random(arr.length)];
	}
	
	public static function string<T>(arr : Array<T>)
	{
		return "[" + Arrays.map(arr, function(v, _) return Dynamics.string(v)).join(", ") + "]";
	}
	
	inline public static function last<T>(arr : Array<T>) : Null<T>
	{
		return arr[arr.length - 1];
	}
	
	public static function lastf<T>(arr : Array<T>, f : T -> Bool) : Null<T>
	{
		var i = arr.length;
		while (--i >= 0)
			if (f(arr[i]))
				return arr[i];
		return null;
	}
	
	inline public static function first<T>(arr : Array<T>) : Null<T>
	{
		return arr[0];
	}
	
	public static function firstf<T>(arr : Array<T>, f : T -> Bool) : Null<T>
	{
		for (v in arr)
			if (f(v))
				return v;
		return null;
	}
	
	inline public static function bisect(a : Array<Float>, x : Float, lo = 0, ?hi : Int)
	{
		return bisectRight(a, x, lo, hi);
	}
	
	public static function bisectRight(a : Array<Float>, x : Float, lo = 0, ?hi : Int)
	{
		if (null == hi)
			hi = a.length;
		while (lo < hi)
		{
			var mid = (lo + hi) >> 1;
			if (x < a[mid])
				hi = mid;
			else
				lo = mid + 1;
		}
		return lo;
	}
	
	public static function bisectLeft(a : Array<Float>, x : Float, lo = 0, ?hi : Int)
	{
		if (null == hi)
			hi = a.length;
		while (lo < hi)
		{
			var mid = (lo + hi) >> 1;
			if (a[mid] < x)
				lo = mid + 1;
			else
				hi = mid;
		}
		return lo;
	}
	
	public static function nearest<T>(a : Array<T>, x : Float, f : T -> Float) : T
	{
		var delta = [];
		for (i in 0...a.length)
			delta.push( { i : i, v : Math.abs(f(a[i]) - x) } );
		delta.sort(function(a, b) return Floats.compare(a.v, b.v));
		return a[delta[0].i];
	}
	
	public static function compare<T>(a : Array<T>, b : Array<T>)
	{
		var v : Int;
		if ((v = Ints.compare(a.length, b.length)) != 0)
			return v;
		for (i in 0...a.length)
		{
			if ((v = Dynamics.compare(a[i], b[i])) != 0)
				return v;
		}
		return 0;
	}
	
	public static function product<T>(a : Array<Array<T>>) : Array<Array<T>>
	{
		var arr = a.copy(),
			result : Array<Array<T>> = [],
			temp : Array<Array<T>>;
		
		for (value in arr[0])
			result.push([value]);
		for (i in 1...arr.length)
		{
			temp = [];
			for (acc in result)
				for (value in arr[i])
					temp.push(acc.copy().concat([value]));
			result = temp;
		}
		return result;
	}
}