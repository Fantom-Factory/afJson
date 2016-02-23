
** Converts objects annotated with '@Serializable { simple = true }'.
@Js
internal const class SerializableConveter : JsonConverter {

	private const Method fromStr
	
	new make(Type type) {
		this.fromStr = type.method("fromStr", true)
	}
	
	override Obj? toJsonObj(JsonConverterCtx ctx, Obj? fantomObj) {
		if (fantomObj == null) return null
		return fantomObj?.toStr
	}

	override Obj? toFantom(JsonConverterCtx ctx, Obj? jsonObj) {
		if (jsonObj == null) return null

		try {
			return fromStr.call(jsonObj)
		} catch (Err err) {
			throw Err("Could not call ${fromStr.qname}() with: ${jsonObj.typeof.qname} ${jsonObj}", err)
		}
	}
}
