
const class JsonTypeMeta {

	** The fantom 'Type' being converted. 
	const Type		type
	
	** The converter used to convert this object. 
	const JsonConverter converter

	** The field, if any, this meta corresponds to.
	const Field?	field

	** The property name used when this value is stored in a JSON object.
	** 
	** Taken from '@JsonProperty.propertyName' and defaults to the field name if not available.
	const Str? 		propertyName

	** The Fantom implementation 'Type' to use when instantiating this object. 
	** Use when this field references a mixin or a superclass. 
	** 
	** Taken from '@JsonProperty.implType' and defaults to the field type if not available.
	const Type? 	implType

	** Dictates whether or not 'null' values are persisted in JSON objects.
	** 
	** If 'null' then the decision is deferred to the 'ObjConverter' implementation, which is 'false' by default.
	** 
	** Note that the 'null' check is performed on the JSON value *after* any conversion. 
	const Bool?		storeNullValues
	
	// NOTE: there is no jsonType as this is wholly determined by the converter.
	// Having a jsonType would only make sense if we had ONE converter that handled everything. 
	
	** If this type models a JSON object, then this is the meta for the containing properties.
	** Returns empty list if there are no properties.
	const Field:JsonTypeMeta	properties	:= emptyMap
	
	** Optional stash of data for use by custom converters.
	const Obj?		stash
	
	** Standard it-block ctor for setting 'const' fields.
	** 
	**   syntax: fantom
	**   meta := JsonTypeMeta {
	**       it.type      = MyType#
	**       it.converter = MyTypeConverter()
	**   }
	new make(|This| f) { f(this) }
	
	// Singleton instance.
	private static const Field:JsonTypeMeta emptyMap := Field:JsonTypeMeta[:]
}
