
** (Service) - 
const class JsonWriter {

	** Convenience for `writeJsonObj` to an in-memory string.
	Str writeJsonObjToStr(Obj? obj) {
		buf := StrBuf()
		writeJsonObj(obj, buf.out)
		return buf.toStr
	}

	** Write the given object as JSON to this stream.
	** The obj must be one of the follow:
	**	 - null
	**	 - Bool
	**	 - Num
	**	 - Str
	**	 - Str:Obj?
	**	 - Obj?[]
	This writeJsonObj(Obj? obj, OutStream out) {
		obj = convertVal(obj)
			 if (obj is Str)	_writeJsonStr	(out, obj)
		else if (obj is Num)	_writeJsonNum	(out, obj)
		else if (obj is Bool)	_writeJsonBool	(out, obj)
		else if (obj is Map)	_writeJsonMap	(out, obj)
		else if (obj is List)	_writeJsonList	(out, obj)
		else if (obj == null)	_writeJsonNull	(out)
		else throw IOErr("Unknown JSON object: ${obj.typeof} - ${obj}")
		return this
	}

	** A simple hook to convert values *before* they are written.
	** 
	** By default this just returns the given value.  
	virtual Obj? convertVal(Obj? val) { val }
	
	// ---- private methods -----------------------------------------------------------------------

	private Void _writeJsonMap(OutStream out, Map map) {
		out.writeChar(JsonToken.objectStart)
		notFirst := false
		map.each |val, key| {
			if (key isnot Str) throw Err("JSON map key is not Str type: $key [$key.typeof]")
			if (notFirst) out.writeChar(JsonToken.comma).writeChar('\n')
			_writeJsonPair(out, key, val)
			notFirst = true
		}
		out.writeChar(JsonToken.objectEnd)
	}

	private Void _writeJsonList(OutStream out, Obj?[] array) {
		out.writeChar(JsonToken.arrayStart)
		notFirst := false
		array.each |item| {
			if (notFirst) out.writeChar(JsonToken.comma)
			writeJsonObj(item, out)
			notFirst = true
		}
		out.writeChar(JsonToken.arrayEnd)
	}

	private Void _writeJsonStr(OutStream out, Str str) {
		out.writeChar(JsonToken.quote)
		str.each |char| {
			if (char <= 0x7f) {
				switch (char) {
					case '\b': out.writeChar('\\').writeChar('b')
					case '\f': out.writeChar('\\').writeChar('f')
					case '\n': out.writeChar('\\').writeChar('n')
					case '\r': out.writeChar('\\').writeChar('r')
					case '\t': out.writeChar('\\').writeChar('t')
					case '\\': out.writeChar('\\').writeChar('\\')
					case '"' : out.writeChar('\\').writeChar('"')
					default	 : out.writeChar(char)
				}
			}
			else {
				out.writeChar('\\').writeChar('u').print(char.toHex(4))
			}
		}
		out.writeChar(JsonToken.quote)
	}

	private Void _writeJsonNum(OutStream out, Num num) {
		out.print(num)
	}

	private Void _writeJsonBool(OutStream out, Bool bool) {
		out.print(bool)
	}

	private Void _writeJsonNull(OutStream out) {
		out.print("null")
	}

	private Void _writeJsonPair(OutStream out, Str key, Obj? val) {
		_writeJsonStr(out, key)
		out.writeChar(JsonToken.colon)
		writeJsonObj(val, out)
	}
}
