
** A utility `JsonConverter` that handles simple serializable types. 
@Js internal const class JsonSimpleConverter : JsonConverter {
	private const Type type

	** Creates a converter for the given type. The type must be annotated with:
	** 
	**   syntax: fantom
	**   @Serializable { simple = true }
	new make(Type type) {
		serializable := (Serializable?) type.facet(Serializable#, false)
		if (serializable == null)
			throw ArgErr("Type '${type.qname}' is not @Serializable")
		if (!serializable.simple)
			throw ArgErr("Type '${type.qname}' is not @Serializable { simple=true }")
		this.type = type
	}

	@NoDoc
	override Obj? toJsonVal(Obj? fantomObj, JsonConverterCtx ctx) {
		fantomObj?.toStr
	}

	@NoDoc
	override Obj? fromJsonVal(Obj? jsonVal, JsonConverterCtx ctx) {
		if (jsonVal == null) return null
		// use 'type' not 'this.type' incase we're passed a subclass
		fromStr := type.method("fromStr", true)
		try return fromStr.call(jsonVal)
		catch (Err err)
			throw Err("Could not call ${fromStr.qname} ${fromStr.signature} with ${jsonVal.typeof.qname}", err)
	}
	
	@NoDoc
	override Str toStr() {
		"Simple Converter for ${type.qname}"
	}
}
