
** A value that is written out verbatim by 'JsonWriter'.
** 
** Use 'JsLiterals' to embed Javascript in your JSON objects. Note that the resultant string is no longer valid JSON. 
@Js @Serializable { simple = true }
class JsLiteral {

	** The literal value.
	Str val
	
	** Creates a 'JsonLiteral'.
	new fromStr(Str val) {
		this.val = val
	}
	
	@NoDoc
	override Str toStr()	{ val }
	@NoDoc
	override Int hash()		{ val.hash }
	@NoDoc
	override Bool equals(Obj? that) {
		(that as JsLiteral)?.val == val
	}
}
