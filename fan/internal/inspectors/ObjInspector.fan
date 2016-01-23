
internal const class ObjInspector : JsonTypeInspector {

	override JsonTypeMeta? inspect(Type objType, JsonInspectors inspectors) {
		map := Field:JsonTypeMeta[:] { it.ordered=true }

		objType.fields.findAll { it.hasFacet(JsonProperty#) }.each |field| {
			prop := (JsonProperty) field.facet(JsonProperty#)
			if (prop.implType != null && prop.implType.fits(field.type).not)
				throw Err(ErrMsgs.objInspect_implTypeDoesNotFit(prop.implType, field))

			type := prop.implType ?: field.type
			meta := inspectors.getOrInspect(type)
			map[field] = JsonTypeMeta {
				it.type		 	= meta.type
				it.converter 	= meta.converter
				it.properties 	= meta.properties
				it.implType	 	= prop.implType 	?: field.type
				it.propertyName	= prop.propertyName	?: field.name
			}
		}

		return JsonTypeMeta {
			it.type		 	= objType
			it.converter 	= ObjConverter()
			it.properties 	= map
		}
	}
}