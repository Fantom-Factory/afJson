
internal const class ObjInspector : JsonInspector {

	override JsonConverterMeta? inspect(Type objType, JsonInspectors inspectors) {
		map := Field:JsonConverterMeta[:] { it.ordered=true }

		objType.fields.findAll { it.hasFacet(JsonProperty#) }.each |field| {
			prop := (JsonProperty) field.facet(JsonProperty#)
			if (prop.implType != null && prop.implType.fits(field.type).not)
				throw Err(ErrMsgs.objInspect_implTypeDoesNotFit(prop.implType, field))

			type := prop.implType ?: field.type
			meta := inspectors.getOrInspect(type)
			map[field] = JsonConverterMeta {
				it.type		 	= meta.type
				it.converter 	= meta.converter
				it.properties 	= meta.properties
				it.implType	 	= prop.implType 	?: field.type
				it.propertyName	= prop.propertyName	?: field.name
			}
		}

		return JsonConverterMeta {
			it.type		 	= objType
			it.converter 	= ObjConverter()
			it.properties 	= map
		}
	}
}