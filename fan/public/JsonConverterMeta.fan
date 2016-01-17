
const class JsonConverterMeta {

	** The fantom 'Type' being converted. 
	const Type		type
	
	** The converter used to convert this object. 
	const JsonConverter converter

	** The implementation 'Type' to use when instantiating this object. 
	** Use when this field references a mixin or a superclass. 
	** 
	** Taken from '@JsonProperty.implType' and defaults to the field type if not available.
	** 
	** Used / set by `JsonObjConverter`.
	const Type? 	implType

	** Should this value be saved in a JSON object, this is the property name it is stored under.
	** The name of the JSON object property this field maps to. 
	** 
	** Taken from '@JsonProperty.propertyName' and defaults to field name if not available.
	** 
	** Used / set by `JsonObjConverter`.
	const Str? 		propertyName

	// NOTE: there is no jsonType as this is wholly determined by the converter.
	// Having a jsonType would only make sense if we had ONE converter that handled everything. 
	
	** If this type models a JSON object, then this is the meta for the containing properties.
	** Returns empty list if there are no properties.
	** 
	** Used / set by `JsonObjConverter`.
	const Field:JsonConverterMeta	properties	:= emptyMap
	
	** Optional stash of data for use by custom converters.
	const Obj?		stash
	
	** Standard it-block ctor.
	new make(|This| f) { f(this) }
	
	// Singleton instance.
	private static const Field:JsonConverterMeta emptyMap := Field:JsonConverterMeta[:]
}
