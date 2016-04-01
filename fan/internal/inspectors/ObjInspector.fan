using afBeanUtils

** The main inspector for Objects. 
** Creates a nested ZZZZ blah by inspecting fields annotated with the '@JsonProperty' facet.
@Js @NoDoc	// Advanced use only!
const class ObjInspector : JsonTypeInspector {

	** Defaults to an instance of 'ObjConverter'.
	const JsonConverter? objConverter
	
	new make(|This|? in := null) {
		in?.call(this)
		if (objConverter == null)
			objConverter = ObjConverter()
	}
	
	override JsonTypeMeta? inspect(Type objType, JsonTypeInspectors inspectors) {
		map := Slot:JsonTypeMeta[:] { it.ordered=true }

		findJsonFields(objType).each |slot| {
			prop := (JsonProperty?) slot.facet(JsonProperty#, false)
			
			defType := (slot as Field)?.type ?: (slot as Method)?.returns
			if (prop?.implType != null && prop.implType.fits(defType).not)
				throw Err(ErrMsgs.objInspect_implTypeDoesNotFit(prop.implType, slot))

			type := prop?.implType ?: defType
			
			if (prop?.converterType != null) {
				map[slot] = JsonTypeMeta {
					it.type		 		= type
					it.field	 		= slot as Field
					it.implType	 		= getImplType(slot, type)
					it.propertyName		= getPropertyName(slot, prop?.propertyName ?: slot.name)
					it.storeNullValues	= prop?.storeNullValues
					it.converter 		= createConverter(prop.converterType)
				}
			} else {
				meta := inspectors.getOrInspect(type)
				map[slot] = JsonTypeMeta {
					it.type		 		= type
					it.field	 		= slot as Field
					it.implType	 		= getImplType(slot, type)
					it.propertyName		= getPropertyName(slot, prop?.propertyName ?: slot.name)
					it.storeNullValues	= prop?.storeNullValues
					it.converter 		= meta.converter
					it.properties 		= meta.properties
					it.stash			= meta.stash
				}
			}
		}

		return JsonTypeMeta {
			it.type		 	= objType
			it.converter 	= createObjConverter
			it.properties 	= map
		}
	}
	
	** Hook to grab all slots (fields) that are to be converted.
	** 
	** By default this returns all slots annotated with the facet '@JsonProperty'.
	virtual Slot[] findJsonFields(Type objType) {
		objType.slots.findAll |slot -> Bool| {
			hasProp := slot.hasFacet(JsonProperty#)
			if (hasProp && slot is Method && ((Method) slot).params.size > 0)
				throw Err("Method should not take any arguments: ${slot.qname}")
			return hasProp
		}
	}
	
	** Hook to create 'JsonConverter' instances. 
	** Used to instantiate types defined by '@Property.converterType'.
	** 
	** By default instances are created with [BeanFactory]`afBeanUtils::BeanFactory`.
	** 
	** Override if you prefer converters to be autobuilt by IoC.
	virtual Obj? createConverter(Type type) {
		BeanFactory(type).create
	}

	** Hook to create 'JsonConverter' instances for Objects.
	** 
	** By default this just returns 'objConverter'.
	virtual Obj? createObjConverter() {
		objConverter
	}

	** Hook to alter the given 'implType'.
	** 
	** Returns 'implType' by default.
	virtual Type getImplType(Slot slot, Type implType) { implType }

	** Hook to alter the given 'propertyName'.
	** 
	** Returns 'propertyName' by default.
	virtual Str getPropertyName(Slot slot, Str propertyName) { propertyName }
}
