using afBeanUtils::ReflectUtils

** The main converter for JSON objects. 
@Js internal const class JsonObjConverter : JsonConverter {

	@NoDoc
	override Obj? toJsonVal(Obj? fantomObj, JsonConverterCtx ctx) {
		if (fantomObj == null) return null
		jsonObj := makeJsonObj(ctx)
		
		findTagData(ctx, fantomObj.typeof).each |field| {
			fieldVal := field.val(fantomObj)
			propName := field.name			
			defVal	 := field.defVal
//			implType := field.type	// it is safer to convert what we actually have
			implType := fieldVal?.typeof ?: field.type

			if (defVal == fieldVal)
				fieldVal = null

			propVal	 := ctx.makeField(implType, field.field, field.jsonProperty, fieldVal).toJsonVal

			// use add, rather than set, so an Err is thrown should we accidently try to add the 
			// same name twice (from using the Property@name facet)
			jsonObj.add(propName, propVal)
		}

		return jsonObj
	}
	
	@NoDoc
	override Obj? fromJsonVal(Obj? jsonVal, JsonConverterCtx ctx) {
		if (jsonVal == null) return null
		fantomType := ctx.type

		// because ObjConverter is a catch-all converter, we sometimes get sent here by mistake
		// or when fields are of type 'Obj?' - so just return the JSON literal
		if (jsonVal isnot Map)
			return jsonVal
//			throw Err(documentConv_noConverter(fantomType, jsonVal))

		jsonObj		:= (Str:Obj?) jsonVal
		fieldVals	:= [Field:Obj?][:]

		if (jsonObj.containsKey("_type"))
			fantomType = Type.find(jsonObj["_type"])

		tagData := findTagData(ctx, fantomType)
		
		if (strictMode(ctx)) {
			tagNames := tagData.map { it.name }
			keyNames := jsonObj.keys
			keyNames = keyNames.removeAll(tagNames)
			if (keyNames.size > 0)
				throw Err("Extraneous data in JSON object for ${ctx.type.qname}: " + keyNames.join(", "))
		}

		tagData.each |field| {
			propName := field.name
			implType := field.type
			propVal  := jsonObj.get(propName, null)

			fieldVal := ctx.makeField(implType, field.field, field.jsonProperty, propVal).fromJsonVal

			if (fieldVal == null && !field.type.isNullable) {
				defVal := field.defVal

				// if a value *is* required then decide which Err msg to throw 
				if (defVal == null)				
					if (jsonObj.containsKey(propName))
						throw Err(documentConv_propertyIsNull(propName, field.field, logRec(jsonObj)))
					else 
						throw Err(documentConv_propertyNotFound(field.field, logRec(jsonObj)))

				fieldVal = defVal
			}
	
			// sanity check we're about to set the correct instance 
			if (fieldVal != null && !ReflectUtils.fits(fieldVal.typeof, field.type))
				throw Err(documentConv_propertyDoesNotFitField(propName, fieldVal.typeof, field.field, logRec(jsonObj)))

			fieldVals[field.field] = fieldVal
		}
		
		return makeEntity(ctx, fieldVals)
	}

	private JsonPropertyData[] findTagData(JsonConverterCtx ctx, Type entityType) {
		((JsonPropertyCache) ctx.options["afJson.propertyCache"]).getOrFindTags(entityType)
	}
	
	** Creates an Entity instance. 
	private Obj? makeEntity(JsonConverterCtx ctx, Field:Obj? fieldVals) {
		((|Type, Field:Obj?->Obj?|) ctx.options["afJson.makeEntity"])(ctx.type, fieldVals)
	}
	
	** Creates an empty *ordered* JSON object. 
	private Str:Obj? makeJsonObj(JsonConverterCtx ctx) {
		((|->Str:Obj?|) ctx.options["afJson.makeJsonObj"])()
	}
	
	private Bool strictMode(JsonConverterCtx ctx) {
		ctx.options.get("afJson.strictMode", false)
	}

	private static const Type[] literals	:= [Bool#, Date#, DateTime#, Str#, Time#, Uri#, Depend#, Decimal#, Duration#, Enum#, Float#, Int#, Locale#, MimeType#, Range#, Regex#, Slot#, TimeZone#, Type#, Unit#, Version#]
	private Str:Str logRec(Map obj) {
		obj.map |val->Str| {
			if (val == null)
				return "null"
			if (literals.contains(val.typeof.toNonNullable))
				return val.toStr
			return "..." 
		}
	}

//	private static Str documentConv_noConverter(Type fantomType, Obj jsonObj) {
//		stripSys("Could not find a Converter to ${fantomType.qname} from '${jsonObj.typeof.qname} - ${jsonObj}'")
//	}
	
	private static Str documentConv_propertyIsNull(Str propName, Field field, Str:Obj? document) {
		stripSys("Dict tag '${propName}' is null but field ${field.qname} is NOT nullable : ${document}")
	}

	private static Str documentConv_propertyNotFound(Field field, Str:Obj? document) {
		stripSys("Dict tag does not contain a property for field ${field.qname} : ${document}")
	}
	
	private static Str documentConv_propertyDoesNotFitField(Str propName, Type propType, Field field, Str:Obj? document) {
		stripSys("Dict tag property '${propName}' of type '${propType.signature}' does not fit field ${field.qname} of type '${field.type.signature}' : ${document}")
	}

	private static Str stripSys(Str str) {
		str.replace("sys::", "")
	}
}
