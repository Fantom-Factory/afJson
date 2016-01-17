
const mixin JsonConverter {
	
	abstract Obj? toJson(JsonConverterCtx ctx, Obj? fantomObj)
	
	abstract Obj? toFantom(JsonConverterCtx ctx, Obj? jsonObj)
}
