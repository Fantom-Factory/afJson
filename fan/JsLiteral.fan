
** A JavaScript literal that is written out verbatim by 'JsonWriter'.
** 
** Use 'JsLiterals' to embed Javascript in your JSON objects. Note that the resultant string is no 
** longer valid JSON, but can sometimes be a good *get out of jail* card.
** 
** pre>
** syntax: fantom
** jsonWriter.writeJson([
**   "func" : JsLiteral("function() { ... }")
** ])
** 
** // --> { "func" : function() { ... } }
** <pre
** 
** Your own classes may extend 'JsLiteral' and their 'toStr()' representation is output in the JSON.
** 
** Note that without 'JsLiteral', the function would be surrounded in quotes:
** 
** pre>
** syntax: fantom
** jsonWriter.writeJson([
**   "func" : "function() { ... }"
** ])
** 
** // --> { "func" : "function() { ... }" }
** <pre
** 
@Js mixin JsLiteral {

	** Creates a 'JsonLiteral' instance.
	static new fromStr(Str val) {
		JsLiteralImpl(val)
	}
}

@Js @Serializable { simple = true }
internal const class JsLiteralImpl : JsLiteral {

	const Str val
	
	new make(Str val) { this.val = val }
	
	override Str toStr()			{ val }
	override Int hash()				{ val.hash }
	override Bool equals(Obj? that)	{ (that as JsLiteralImpl)?.val == val }
}
