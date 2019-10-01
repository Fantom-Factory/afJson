
@Js internal const class JsonEnumConverter : JsonConverter {
	
	override Obj? toJsonVal(Obj? fantomObj, JsonConverterCtx ctx) {
		if (fantomObj == null) return null
		return ((Enum) fantomObj).name
	}

	override Obj? fromJsonVal(Obj? jsonVal, JsonConverterCtx ctx) {
		if (jsonVal == null) return null
		return ctx.type.method("fromStr").call(jsonVal, true)
	}
}
