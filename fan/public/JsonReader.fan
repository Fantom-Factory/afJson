
** (Service) - 
** Reads Fantom objects from JSON.
@Js
const class JsonReader {

	** Default ctor.
	new make() { }
	
	** Reads an object from the given JSON stream and returns one of the following:
	**	 - 'null'
	**	 - 'Bool'
	**	 - 'Int'
	**	 - 'Float'
	**	 - 'Str'
	**	 - 'Str:Obj?'
	**	 - 'Obj?[]'
	** 
	** If 'closeStream' is 'true', the given 'InStream' is guarenteed to be closed.
	Obj? readJsonFromStream(InStream? in, Bool closeStream := true) {
		if (in == null)
			return null

		ctx := JsonReadCtx(in)
		try {
			ctx.consume
			ctx.skipWhitespace
			return _parseVal(ctx)
			
		} finally
			if (closeStream)
				in.close
	}

	** Translates the given JSON to its Fantom representation. 
	** The returned 'Obj' may be any `JsonLiteral`.
	** 
	** Convenience for 'readJsonFromStream(json?.in)'
	Obj? readJson(Str? json) {
		readJsonFromStream(json?.in)
	}

	** Translates the given JSON to its Fantom List representation. 
	** 
	** Convenience for '(Obj?[]?) readJson(...)'
	Obj?[]? readJsonAsList(Str? json) {
		readJson(json)
	}

	** Translates the given JSON to its Fantom Map representation. 
	** 
	** Convenience for '([Str:Obj?]?) readJson(...)'
	[Str:Obj?]? readJsonAsMap(Str? json) {
		readJson(json)
	}

	** A simple override hook to alter values *after* they have been read.
	** 
	** By default this just returns the given value.  
	virtual Obj? convertHook(Obj? val) { val }


	
	// ---- private methods -----------------------------------------------------------------------
	
	private Obj? _parseVal(JsonReadCtx ctx) {
			 if (ctx.cur == JsonToken.quote)		return convertHook(_parseStr(ctx))
		else if (ctx.cur.isDigit || ctx.cur == '-')	return convertHook(_parseNum(ctx))
		else if (ctx.cur == JsonToken.objectStart)	return convertHook(_parseObj(ctx))
		else if (ctx.cur == JsonToken.arrayStart)	return convertHook(_parseArray(ctx))
		else if (ctx.cur == 't') {
			"true".size.times |->| { ctx.consume }
			return convertHook(true)
		}
		else if (ctx.cur == 'f') {
			"false".size.times |->| { ctx.consume }
			return convertHook(false)
		}
		else if (ctx.cur == 'n') {
			"null".size.times |->| { ctx.consume }
			return convertHook(null)
		}

		if (ctx.cur < 0) throw ctx.err("Unexpected end of stream")
		throw ctx.err("Unexpected token " + ctx.cur)
	}

	private Str:Obj? _parseObj(JsonReadCtx ctx) {
		pairs := Str:Obj?[:] { ordered = true }

		ctx.skipWhitespace

		ctx.expect(JsonToken.objectStart)

		while (true) {
			ctx.skipWhitespace
			if (ctx.maybe(JsonToken.objectEnd)) return pairs
			_parsePair(ctx, pairs)
			if (!ctx.maybe(JsonToken.comma)) break
		}

		ctx.expect(JsonToken.objectEnd)

		return pairs
	}

	private Void _parsePair(JsonReadCtx ctx, Str:Obj? obj) {
		ctx.skipWhitespace
		key := _parseStr(ctx)

		ctx.skipWhitespace

		ctx.expect(JsonToken.colon)
		ctx.skipWhitespace

		val := _parseVal(ctx)
		ctx.skipWhitespace

		obj[key] = val
	}

	private Obj _parseNum(JsonReadCtx ctx) {
		integral	:= StrBuf()
		fractional	:= StrBuf()
		exponent	:= StrBuf()
		if (ctx.maybe('-'))
			integral.add("-")

		while (ctx.cur.isDigit) {
			integral.addChar(ctx.cur)
			ctx.consume
		}

		if (ctx.cur == '.') {
			decimal := true
			ctx.consume
			while (ctx.cur.isDigit) {
				fractional.addChar(ctx.cur)
				ctx.consume
			}
		}

		if (ctx.cur == 'e' || ctx.cur == 'E') {
			exponent.addChar(ctx.cur)
			ctx.consume
			if (ctx.cur == '+') ctx.consume
			else if (ctx.cur == '-') {
				exponent.addChar(ctx.cur)
				ctx.consume
			}
			while (ctx.cur.isDigit) {
				exponent.addChar(ctx.cur)
				ctx.consume
			}
		}

		Num? num := null
		if (fractional.size > 0)
			num = Float.fromStr(integral.toStr + "." + fractional.toStr + exponent.toStr)
		else if (exponent.size > 0)
			num = Float.fromStr(integral.toStr+exponent.toStr)
		else num = Int.fromStr(integral.toStr)

		return num
	}

	private Str _parseStr(JsonReadCtx ctx) {
		s := StrBuf()
		ctx.expect(JsonToken.quote)
		while (ctx.cur != JsonToken.quote ) {
			if (ctx.cur < 0) throw ctx.err("Unexpected end of str literal")
			if (ctx.cur == '\\') {
				s.addChar(ctx.escape)
			}
			else {
				s.addChar(ctx.cur)
				ctx.consume
			}
		}
		ctx.expect(JsonToken.quote)
		return s.toStr
	}

	private List _parseArray(JsonReadCtx ctx) {
		array := [,]
		ctx.expect(JsonToken.arrayStart)
		ctx.skipWhitespace
		if (ctx.maybe(JsonToken.arrayEnd)) return array

		while (true) {
			ctx.skipWhitespace
			val := _parseVal(ctx)
			array.add(val)
			ctx.skipWhitespace
			if (!ctx.maybe(JsonToken.comma)) break
		}
		ctx.skipWhitespace
		ctx.expect(JsonToken.arrayEnd)
		return array
	}
}

** JsonToken represents the tokens in JSON.
@Js
internal mixin JsonToken {
	static const Int objectStart	:= '{'
	static const Int objectEnd		:= '}'
	static const Int colon			:= ':'
	static const Int arrayStart		:= '['
	static const Int arrayEnd		:= ']'
	static const Int comma			:= ','
	static const Int quote			:= '"'
}

@Js
internal class JsonReadCtx {

	private InStream	in
			Int 		cur := '?'
			Int			pos := 0

	new make(InStream in) {
		this.in	= in
	}
	
	Int escape() {
		// consume slash
		expect('\\')

		// check basics
		switch (cur) {
			case 'b':	consume; return '\b'
			case 'f':	consume; return '\f'
			case 'n':	consume; return '\n'
			case 'r':	consume; return '\r'
			case 't':	consume; return '\t'
			case '"':	consume; return '"'
			case '\\':	consume; return '\\'
			case '/':	consume; return '/'
		}

		// check for uxxxx
		if (cur == 'u') {
			consume
			n3 := cur.fromDigit(16); consume
			n2 := cur.fromDigit(16); consume
			n1 := cur.fromDigit(16); consume
			n0 := cur.fromDigit(16); consume
			if (n3 == null || n2 == null || n1 == null || n0 == null) throw err("Invalid hex value for \\uxxxx")
			return n3.shiftl(12).or(n2.shiftl(8)).or(n1.shiftl(4)).or(n0)
		}

		throw err("Invalid escape sequence")
	}

	Void skipWhitespace() {
		while (cur.isSpace)
			consume
	}

	Void expect(Int tt) {
		if (cur < 0)	throw err("Unexpected end of stream, expected ${tt.toChar}")
		if (cur != tt)	throw err("Expected ${tt.toChar}, got ${cur.toChar} at ${pos}")
		consume
	}

	Bool maybe(Int tt) {
		if (cur != tt) return false
		consume
		return true
	}

	Void consume() {
		cur = in.readChar ?: -1
		pos++
	}
	
	Err err(Str msg) { ParseErr(msg) }
}
