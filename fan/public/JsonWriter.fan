
** (Service) - 
** Writes Fantom objects to JSON, optionally performing pretty printing.
** 
** Pretty printing takes more processing than basic printing, but helps debugging.
@Js
const class JsonWriter {

	** Default options used for pretty printing.
	** 
	** If 'null' then the default is to NOT pretty print.
	const PrettyPrintOptions? prettyPrintOptions := null
	
	** Creates a 'JsonWriter' with the default pretty printing options. 
	** May be either a 'PrettyPrintOptions' instance, or just 'true' to enable pretty printing 
	** with defaults. 
	** 
	** If 'null' then the default is to NOT pretty print.
	** 
	**   syntax: fantom
	**   writer := JsonWriter()
	**   writer := JsonWriter(true)
	**   writer := JsonWriter(PrettyPrintOptions { it.indent = "\t" })
	new make(Obj? prettyPrintOptions := null) {
		if (prettyPrintOptions != null) {
			if (prettyPrintOptions == false)
				return
			if (prettyPrintOptions == true)
				return this.prettyPrintOptions = PrettyPrintOptions()
			this.prettyPrintOptions = prettyPrintOptions			
		}
	}
	
	** Convenience for serialising the given Fantom object to JSON.
	** 
	** 'prettyPrintOptions' may be either a 'PrettyPrintOptions' instance, or just 'true' to enable 
	** pretty printing with defaults. If 'null' then it defaults to the class default.
	** 
	**   syntax: fantom
	**   json := jsonWriter.writeJson(jsonObj)
	**   json := jsonWriter.writeJson(jsonObj, true)
	**   json := jsonWriter.writeJson(jsonObj, PrettyPrintOptions { it.indent = "\t" })
	** 
	Str writeJson(Obj? obj, Obj? prettyPrintOptions := null) {
		buf := StrBuf()
		writeJsonToStream(obj, buf.out, prettyPrintOptions ?: this.prettyPrintOptions)
		return buf.toStr
	}

	** Write the given object as JSON to this stream.
	** The obj must be one of the following:
	**	 - 'null'
	**	 - 'Bool'
	**	 - 'Num'
	**	 - 'Str'
	**	 - 'Str:Obj?'
	**	 - 'Obj?[]'
	** 
	** 'prettyPrintOptions' may be either a 'PrettyPrintOptions' instance, or just 'true' to enable 
	** pretty printing with defaults.
	**  
	**   syntax: fantom
	**   jsonWriter.writeJsonToStream(jsonObj, out)
	**   jsonWriter.writeJsonToStream(jsonObj, out, true)
	**   jsonWriter.writeJsonToStream(jsonObj, out, PrettyPrintOptions { it.indent = "\t" })
	** 
	This writeJsonToStream(Obj? obj, OutStream out, Obj? prettyPrintOptions := null) {
		ctx := JsonWriteCtx(out, prettyPrintOptions ?: this.prettyPrintOptions)
		_writeJsonToStream(ctx, obj)
		ctx.finalise
		return this
	}

	** A simple override hook to alter values *before* they are written.
	** 
	** By default this just returns the given value.  
	virtual Obj? convertHook(Obj? val) { val }
	 
	// ---- private methods -----------------------------------------------------------------------

	private This _writeJsonToStream(JsonWriteCtx ctx, Obj? obj) {
		obj = convertHook(obj)
			 if (obj is Str)		_writeJsonStr	(ctx, obj)
		else if (obj is Num)		_writeJsonNum	(ctx, obj)
		else if (obj is Bool)		_writeJsonBool	(ctx, obj)
		else if (obj is Map)		_writeJsonMap	(ctx, obj)
		else if (obj is List)		_writeJsonList	(ctx, obj)
		else if (obj is JsLiteral)	_writeJsonLit	(ctx, obj)
		else if (obj == null)		_writeJsonNull	(ctx)
		else throw IOErr("Unknown JSON object: ${obj.typeof} - ${obj}")
		return this
	}
	
	private Void _writeJsonMap(JsonWriteCtx ctx, Map map) {
		ctx.objectStart
		notFirst := false
		map.each |val, key| {
			if (key isnot Str) throw Err("JSON map key is not Str type: $key [$key.typeof]")
			if (notFirst) ctx.objectVal
			_writeJsonStr(ctx, key)
			ctx.objectKey
			_writeJsonToStream(ctx, val)
			notFirst = true
		}
		ctx.objectEnd
	}

	private Void _writeJsonList(JsonWriteCtx ctx, Obj?[] array) {
		ctx.arrayStart
		notFirst := false
		array.each |item| {
			if (notFirst) ctx.arrayItem
			_writeJsonToStream(ctx, item)
			notFirst = true
		}
		ctx.arrayEnd
	}

	private Void _writeJsonStr(JsonWriteCtx ctx, Str str) {
		ctx.valueStart
		ctx.writeChar(JsonToken.quote)
		str.each |char| {
			if (char <= 0x7f) {
				switch (char) {
					case '\b': ctx.writeChar('\\').writeChar('b')
					case '\f': ctx.writeChar('\\').writeChar('f')
					case '\n': ctx.writeChar('\\').writeChar('n')
					case '\r': ctx.writeChar('\\').writeChar('r')
					case '\t': ctx.writeChar('\\').writeChar('t')
					case '\\': ctx.writeChar('\\').writeChar('\\')
					case '"' : ctx.writeChar('\\').writeChar('"')
					
					// note '/' may be escaped but doesn't have to be
					// see http://stackoverflow.com/questions/1580647/json-why-are-forward-slashes-escaped
					//case '/' : ctx.writeChar('\\').writeChar('/')
					default	 : ctx.writeChar(char)
				}
			}
			else {
				ctx.writeChar('\\').writeChar('u').print(char.toHex(4))
			}
		}
		ctx.writeChar(JsonToken.quote)
		ctx.valueEnd
	}

	private Void _writeJsonLit(JsonWriteCtx ctx, JsLiteral lit) {
		ctx.valueStart.print(lit.val).valueEnd
	}

	private Void _writeJsonNum(JsonWriteCtx ctx, Num num) {
		ctx.valueStart.print(num).valueEnd
	}

	private Void _writeJsonBool(JsonWriteCtx ctx, Bool bool) {
		ctx.valueStart.print(bool).valueEnd
	}

	private Void _writeJsonNull(JsonWriteCtx ctx) {
		ctx.valueStart.print("null").valueEnd
	}
}

@Js
internal mixin JsonWriteCtx {
	static new make(OutStream out, Obj? prettyPrintOptions) {
		if (prettyPrintOptions != null) {
			if (prettyPrintOptions == false)
				return JsonWriteCtxUgly(out)

			ppOpts := prettyPrintOptions == true ? PrettyPrintOptions() : prettyPrintOptions 
			return JsonWriteCtxPretty(out, ppOpts)
		}
		return JsonWriteCtxUgly(out)
	}
	
	abstract This valueStart()
	abstract This print(Obj s)
	abstract This writeChar(Int char)
	abstract This valueEnd()
	
	abstract Void arrayStart()
	abstract Void arrayItem()
	abstract Void arrayEnd()

	abstract Void objectStart()
	abstract Void objectKey()
	abstract Void objectVal()
	abstract Void objectEnd()

	abstract Void finalise()
}

@Js
internal class JsonWriteCtxPretty : JsonWriteCtx {
	private OutStream 			out
	private PrettyPrintOptions	ppOpts
	private Int 				indent		:= 0
	
	private JsonValWriter?		last
	private JsonValWriter[]		valWriters	:= JsonValWriter[,]

	new make(OutStream out, PrettyPrintOptions ppOpts) {
		this.out	= out
		this.ppOpts	= ppOpts
	}
	
	override This print(Obj s) {
		valWriters.peek.writeJson(s)
		return this
	}
	
	override This writeChar(Int ch) {
		valWriters.peek.writeChar(ch)
		return this
	}

	override This valueStart()	{ valWriters.push(JsonValWriterLit(ppOpts)); return this }
	override This valueEnd()	{ writerEnd	}
	
	override Void arrayStart()	{ valWriters.push(JsonValWriterList(ppOpts)) }
	override Void arrayItem()	{ }
	override Void arrayEnd()	{ writerEnd	}
	
	override Void objectStart()	{ valWriters.push(JsonValWriterMap(ppOpts)) }
	override Void objectKey()	{ }
	override Void objectVal()	{ }
	override Void objectEnd()	{ writerEnd	}
	
	override Void finalise()	{ out.writeChars(last.str) }
	
	private This writerEnd() {
		last = valWriters.pop
		peek := valWriters.peek
		peek?.add(last.str)
		return this
	}
}

@Js
internal abstract class JsonValWriter {
	PrettyPrintOptions	ppOpts

	new make(PrettyPrintOptions ppOpts) {
		this.ppOpts	= ppOpts
	}
	
	virtual  Void writeJson(Obj ob) { throw Err("WTF?") }
	virtual  Void writeChar(Int ch)	{ throw Err("WTF?") }
	virtual  Void add(Str item)		{ throw Err("WTF?")	}
	abstract Str  str()
}

@Js
internal class JsonValWriterLit : JsonValWriter {
	private StrBuf	value	:= StrBuf(32)
	
	new make(PrettyPrintOptions ppOpts) : super(ppOpts) { }

	override Void writeJson(Obj ob)	{ value.add(ob)	}
	override Void writeChar(Int ch)	{ value.addChar(ch)	}
	override Str str() 				{ value.toStr		}
}

@Js
internal class JsonValWriterList : JsonValWriter {
	private Int		size	:= 1
	private Str[]	list	:= Str[,]

	new make(PrettyPrintOptions ppOpts) : super(ppOpts) { }

	override Void add(Str item)	{
		list.add(item)
		size += item.size + 2
	}

	override Str str() {
		size -= 2
		size += 1
		if (size > ppOpts.maxWidth) {
			// bufSize is only approx unless we start counting the lines in items
			bufSize := size + (list.size * ppOpts.indent.size * 2)
			json := StrBuf(bufSize)
			json.addChar(JsonToken.arrayStart).addChar('\n')
			list.each |item, i| {
				lines := item.splitLines
				lines.each |line, j| {
					json.add(ppOpts.indent).add(line)
					if (j < lines.size-1)
						json.addChar('\n')
				}
				if (i < list.size - 1)
					json.addChar(JsonToken.comma)
				json.addChar('\n')
			}
			json.addChar(JsonToken.arrayEnd)
			return json.toStr
		} else
			return "[" + list.join(", ") + "]"
	}
}

@Js
internal class JsonValWriterMap : JsonValWriter {	
	private Str[]	keys		:= Str[,]
	private Str[]	vals		:= Str[,]
	private Int		size		:= 1
	private Int		maxKeySize	:= 0
	private Int		maxValSize	:= 0
	
	new make(PrettyPrintOptions ppOpts) : super(ppOpts) { }

	override Void add(Str item) {
		(keys.size > vals.size ? vals : keys).add(item)
		size += item.size + 2
		if (keys.size > vals.size)
			maxKeySize = maxKeySize.max(item.size)
		else
			maxValSize = maxValSize.max(item.size)
	}

	override Str str() {
		size -= 2
		size += 1
		maxKeySize := maxKeySize + 1
		if (size > ppOpts.maxWidth) {
			// bufSize is only approx unless we start counting the lines in vals
			bufSize := (keys.size * maxKeySize) + (vals.size * maxValSize) + (keys.size * ppOpts.indent.size * 2)
			json := StrBuf(bufSize)
			json.addChar(JsonToken.objectStart).addChar('\n')
			
			keys.each |key, i| {
				val := vals[i]
				
				json.add(ppOpts.indent)
				json.add(key.justl(maxKeySize))
				json.addChar(JsonToken.colon)
				json.addChar(' ')
				
				lines := val.splitLines
				json.add(lines.first)
				if (lines.size > 1)
					lines.eachRange(1..-1) |line, j| {
						json.addChar('\n')
						json.add(ppOpts.indent).add(line)
					}
				if (i < keys.size - 1)
					json.addChar(JsonToken.comma)
				json.addChar('\n')
			}
			
			json.addChar(JsonToken.objectEnd)
			return json.toStr

		} else {
			json := StrBuf(size)
			json.addChar(JsonToken.objectStart)
			keys.each |key, i| {
				val := vals[i]
				json.add(key).addChar(JsonToken.colon).addChar(' ').add(val)
				if (i < keys.size - 1)
					json.addChar(JsonToken.comma).addChar(' ')
			}
			json.addChar(JsonToken.objectEnd)
			return json.toStr
		}
	}
}

@Js
internal class JsonWriteCtxUgly : JsonWriteCtx {
	private OutStream	out

	new make(OutStream out) {
		this.out = out
	}
	
	override This print(Obj s) {
		out.print(s)
		return this
	}
	
	override This writeChar(Int char) {
		out.writeChar(char)
		return this
	}
	
	override This valueStart()		{ this									}
	override This valueEnd()		{ this									}
	
	override Void arrayStart()		{ out.writeChar(JsonToken.arrayStart)	}
	override Void arrayItem()		{ out.writeChar(JsonToken.comma)		}
	override Void arrayEnd()		{ out.writeChar(JsonToken.arrayEnd)		}

	override Void objectStart()		{ out.writeChar(JsonToken.objectStart)	}
	override Void objectKey()		{ out.writeChar(JsonToken.colon)		}
	override Void objectVal()		{ out.writeChar(JsonToken.comma)		}
	override Void objectEnd()		{ out.writeChar(JsonToken.objectEnd)	}

	override Void finalise()		{ 										}
}

** Options to pass to 'JsonWriter'.
** 
**   syntax: fantom
**   writer := JsonWriter(PrettyPrintOptions { it.indent = "\t" })
@Js
const class PrettyPrintOptions {

	** The indent string used to indent the JSON.
	const Str 	indent		:= "  "

	** The maximum width of a list or map before it is broken up into separate lines.
	const Int 	maxWidth	:= 80	

	** Default 'it-block' ctor.
	new make(|This|? in := null) { in?.call(this) }
	
	override Str toStr() {
		"indent=${indent.toCode}, maxWidth = ${maxWidth}"
	}
}
