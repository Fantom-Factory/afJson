
** Store Dates as DateTime str objects so they have a native implementation.
internal const class DateConverter : JsonConverter {

	override Obj? toJson(JsonConverterCtx ctx, Obj? fantomObj) {
		if (fantomObj == null) return null
		return ((Date) fantomObj).toDateTime(Time.defVal)
	}

	override Obj? toFantom(JsonConverterCtx ctx, Obj? jsonObj) {
		if (jsonObj == null) return null
		return ((DateTime) jsonObj).date
	}
}
