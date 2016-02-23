
** JSON literals pass straight through, as there's nothing to convert!
@NoDoc @Js
const class LiteralConverter : JsonConverter {

	override Obj? toJsonObj(JsonConverterCtx ctx, Obj? fantomObj)	{ fantomObj }

	override Obj? toFantom(JsonConverterCtx ctx, Obj? jsonObj)	{ jsonObj }
}
