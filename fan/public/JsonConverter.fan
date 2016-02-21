
** Implement to define a custom Fantom '<->' JSON converter.
@Js
const mixin JsonConverter {
	
	** Converts the given 'fantomObj' to its JSON representation.
	abstract Obj? toJson(JsonConverterCtx ctx, Obj? fantomObj)
	
	** Converts the given 'jsonObj' to its Fantom representation.
	abstract Obj? toFantom(JsonConverterCtx ctx, Obj? jsonObj)
}
