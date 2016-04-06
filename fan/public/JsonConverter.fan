
** Implement to define a custom Fantom Obj '<->' JsonObj converter.
@Js
const mixin JsonConverter {

	** Converts the given 'entity' to its JSON representation.
	abstract Obj? toJsonObj(JsonConverterCtx ctx, Obj? entity)
	
	** Converts the given 'jsonObj' to a Fantom entity.
	abstract Obj? toFantom(JsonConverterCtx ctx, Obj? jsonObj)
}
