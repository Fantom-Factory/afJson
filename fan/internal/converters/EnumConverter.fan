
internal const class EnumConverter : JsonConverter {

	override Obj? toJson(JsonConverterCtx ctx, Obj? fantomObj) {
		if (fantomObj == null) return null
		return ((Enum) fantomObj).name
	}

	override Obj? toFantom(JsonConverterCtx ctx, Obj? jsonObj) {
		if (jsonObj == null) return null
		return ctx.meta.type.method("fromStr").call(jsonObj, true)
	}	
}
