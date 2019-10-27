
@Js internal const class JsonDateTimeConverter : JsonConverter {
	
	override Obj? toJsonVal(Obj? fantomObj, JsonConverterCtx ctx) {
		if (fantomObj == null) return null
		return ((DateTime) fantomObj).toLocale(ctx.optDateTimeFormat)
	}

	override Obj? fromJsonVal(Obj? jsonVal, JsonConverterCtx ctx) {
		if (jsonVal == null) return null
		return DateTime.fromLocale(jsonVal, ctx.optDateTimeFormat)
	}
}
