
** JSON literals pass straight through.
@Js internal const class JsonLiteralConverter : JsonConverter {
	
	override Obj? toJsonVal(Obj? fantomObj, JsonConverterCtx ctx) { fantomObj }

	override Obj? fromJsonVal(Obj? jsonVal, JsonConverterCtx ctx) { jsonVal }

}
