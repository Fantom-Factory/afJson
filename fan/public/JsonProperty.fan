
** Marks a field as a property of a JSON document.
facet class JsonProperty {

	** Name of the JSON object property this field maps to. 
	** 
	** Defaults to the field name.
	const Str? 	propertyName
	
	** The implementation 'Type' to use when instantiating this object. 
	** Use when this field references a mixin or a superclass. 
	** 
	** Defaults to the field type.
	const Type? implType

	// FIXME converterType
	** Use to name a custom JSON '<->' Fantom Converter. The type should extend 'JsonConverter'.
	** 
	** The converter should have a no-args ctor or, if using IoC, a ctor suitable for autobuild. 
	const Type? converterType
}
