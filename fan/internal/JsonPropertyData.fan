using afBeanUtils::ReflectUtils

// FIXME make public in FOM ?
** Holds resolved '@JsonProperty' values.
@Js @NoDoc
const class JsonPropertyData {
	
	** The backing storage field.
	const	Field field
	
	** The 'JsonProperty' facet on the field (if any).
	const	JsonProperty? jsonProperty
	
	** Name of the JSON property name this field maps to.
	const	Str	name
	
	** The implementation 'Type' to be instantiated.
	const	Type type
	
	** The default values that maps to 'null'.
	const	Obj? defVal
	
	** Creates a 'JsonPropertyData' instance from a 'Field' - must have the '@JsonProperty' facet.
	new make(Field field, |This|? fn := null) {
		this.jsonProperty	= field.facet(JsonProperty#, true)
		this.field			= field
		this.name			= jsonProperty.name		?: field.name
		this.type			= jsonProperty.implType	?: field.type
		this.defVal			= jsonProperty.defVal
		
		fn?.call(this)
		
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
		stripSys("@JsonProperty.implType of type '${facetType.signature}' does not fit field '${field.type.qname} ${field.qname}'")
	}

	static Str msgFacetDefValDoesNotFitField(Type facetType, Field field) {
		stripSys("@JsonProperty.defVal of type '${facetType.signature}' does not fit field '${field.type.qname} ${field.qname}'")
	}

	private static Str stripSys(Str str) {
		str.replace("sys::", "")
	}

	** Returns the field's value on the given instance.
	virtual Obj? val(Obj obj) {
		field.get(obj)
	}

	override Str toStr() { name }
}
