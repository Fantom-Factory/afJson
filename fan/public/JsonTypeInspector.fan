
** Implement to define a generic strategy for mapping Fantom types to [JsonConverters]`JsonConverter`.
@Js
const mixin JsonTypeInspector {

	** Inspects the given type and returns meta that defines the Fantom '<->' JSON mapping.
	** 
	** 'inspectors' is passed so inspection may recurse into embedded objects.
	** 
	** Implementations should return 'null' if they are not responsible for converting the given type.
	abstract JsonTypeMeta? inspect(Type type, JsonTypeInspectors inspectors)
	
}
