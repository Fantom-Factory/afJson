using afBeanUtils::ReflectUtils

** Holds resolved '@JsonProperty' values.
@NoDoc
@Js internal const mixin JsonPropertyData {
	
	** The backing storage field.
	abstract	Field	field()
	
	** The 'JsonProperty' facet on the field (if any).
	abstract	JsonProperty?	jsonProperty()
	
	** Name of the JSON property name this field maps to.
	abstract	Str		name()
	
	** The implementation 'Type' to be instantiated.
	abstract	Type	type()
	
	** The default values that maps to 'null'.
	abstract	Obj?	defVal()

	** Returns the field's value on the given instance.
	virtual Obj? val(Obj obj) {
		field.get(obj)
	}
	
	** Creates a 'JsonPropertyData' instance from a 'Field' - must have the '@JsonProperty' facet.
	static new make(Field tagField) {
		JsonPropertyDataField(tagField)
	}
}

@Js internal const class JsonPropertyDataField : JsonPropertyData {
	override const Field			field
	override const JsonProperty?	jsonProperty
	override const Str				name
	override const Type				type
	override const Obj?				defVal
	
	new make(Field field) {
		this.jsonProperty	= field.facet(JsonProperty#, true)
		this.field			= field
		this.name			= jsonProperty.name		?: field.name
		this.type			= jsonProperty.implType	?: field.type
		this.defVal			= jsonProperty.defVal
		
		if (!ReflectUtils.fits(type, field.type))
			throw Err(msgFacetTypeDoesNotFitField(type, field))

		// ReflectUtils.fits is too lenient for our purposes here 
		if (defVal is List && ((List) defVal).isEmpty && !defVal.typeof.fits(field.type))
			defVal = field.type.params["V"].emptyList

		// ReflectUtils.fits is too lenient for our purposes here 
		if (defVal is Map && ((Map) defVal).isEmpty && !defVal.typeof.fits(field.type))
			defVal = Map.make(field.type)
		
		if (defVal != null && !ReflectUtils.fits(defVal.typeof, field.type))
			throw Err(msgFacetDefValDoesNotFitField(defVal.typeof, field))
	}
	
	private static Str msgFacetTypeDoesNotFitField(Type facetType, Field field) {
		stripSys("@FomProp.implType of type '${facetType.signature}' does not fit field '${field.type.qname} ${field.qname}'")
	}

	static Str msgFacetDefValDoesNotFitField(Type facetType, Field field) {
		stripSys("@FomProp.defVal of type '${facetType.signature}' does not fit field '${field.type.qname} ${field.qname}'")
	}

	private static Str stripSys(Str str) {
		str.replace("sys::", "")
	}
	
	override Str toStr() { name }
}
