
** Marks a field as a property of a JSON object.
@Js facet class JsonProperty {

	** Name of the JSON property name this field maps to. 
	** 
	** Defaults to the field name.
	const Str?  name

	** The implementation 'Type' to be instantiated should this field reference a mixin or a superclass. 
	** Used when mapping from JSON objects to Fantom objects. 
	** 
	** Defaults to the field type.
	const Type? implType

	** When converting to JSON, any Fantom value that equals this 'defVal' will be treated as if 
	** it were 'null' and (depending on 'ObjConverter') will *not* exist in the JSON object.
	** 
	** When converting from JSON, any 'null' value will be converted to this 'defVal'.
	** 
	** This is most useful for saving marker booleans and to avoid saving empty lists and maps.
	const Obj? defVal
}
