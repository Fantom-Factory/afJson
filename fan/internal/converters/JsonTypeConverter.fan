
@Js internal const class JsonTypeConverter : JsonConverter {
	
	override Obj? toJsonVal(Obj? fantomObj, JsonConverterCtx ctx) {
		if (fantomObj == null) return null
		return ((Type) fantomObj).signature
	}

	override Obj? fromJsonVal(Obj? jsonVal, JsonConverterCtx ctx) {
		if (jsonVal == null) return null
		return Type.find((Str) jsonVal)
	}
}
