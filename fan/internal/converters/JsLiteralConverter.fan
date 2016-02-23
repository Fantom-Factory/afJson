
** Converts to and from JsLiterals. The given type must have a 'fromStr()' ctor.
@NoDoc @Js
const class JsLiteralConverter : JsonConverter {

	private const Method fromStr
	
	new make(Type type) {
		this.fromStr = type.method("fromStr", true)
	}

	override Obj? toJsonObj(JsonConverterCtx ctx, Obj? fantomObj)	{
		if (fantomObj == null) return null
		return JsLiteral(fantomObj.toStr)
	}

	override Obj? toFantom(JsonConverterCtx ctx, Obj? jsonObj)	{
		if (jsonObj == null) return null

		try {
			return fromStr.call(jsonObj)
		} catch (Err err) {
			throw Err("Could not call ${fromStr.qname}() with: ${jsonObj.typeof.qname} ${jsonObj}", err)
		}
	}
}
