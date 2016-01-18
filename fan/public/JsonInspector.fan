
** Implement to define a strategy for mapping Fantom types to [JsonConverters]`JsonConverter`.
const mixin JsonInspector {

	** Inspects the given type and returns meta that defines the Fantom '<->' JSON mapping.
	** 
	** 'inspectors' is passed so inspection may recurse into embedded objects.  
	abstract JsonConverterMeta? inspect(Type type, JsonInspectors inspectors)
	
}


