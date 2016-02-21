
** JSON literals pass straight through, as there's nothing to convert!
@Js
internal const class LiteralConverter : JsonConverter {

	override Obj? toJson(JsonConverterCtx ctx, Obj? fantomObj)	{ fantomObj }

	override Obj? toFantom(JsonConverterCtx ctx, Obj? jsonObj)	{ jsonObj }
}
