
** Implement to convert custom Fantom types to / from a JSON representation. 
@Js const mixin JsonConverter {
	
	** Converts a Fantom object to its JSON representation. 
	** 
	** Must return a valid JSON value (or a List or Map thereof).
	** 
	** 'fantomObj' is nullable so converters can create empty / default objects.
	abstract Obj? toJsonVal(Obj? fantomObj, JsonConverterCtx ctx)

	** Converts a JSON value to Fantom.
	** 
	** 'jsonVal' is nullable so converters can create empty / default objects.
	abstract Obj? fromJsonVal(Obj? jsonVal, JsonConverterCtx ctx)
	
}
