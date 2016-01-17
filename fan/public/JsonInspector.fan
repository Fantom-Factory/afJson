
** Inspects a Fantom type and returns a JsonObjMeta instance that describes how the type may be converted to / from JSON.
const mixin JsonInspector {

	abstract JsonConverterMeta? inspect(Type type, JsonInspectors inspectors)
	
}


