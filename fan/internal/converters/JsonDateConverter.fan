
@Js internal const class JsonDateConverter : JsonConverter {
	
	override Obj? toJsonVal(Obj? fantomObj, JsonConverterCtx ctx) {
		if (fantomObj == null) return null
		return ((Date) fantomObj).toLocale(ctx.optDateFormat)
	}

	override Obj? fromJsonVal(Obj? jsonVal, JsonConverterCtx ctx) {
		if (jsonVal == null) return null
		return Date.fromLocale(jsonVal, ctx.optDateFormat)
	}
}
