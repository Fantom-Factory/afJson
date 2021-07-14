using afBeanUtils::ReflectUtils

** The main converter for JSON objects. 
@Js internal const class JsonObjConverter : JsonConverter {

	@NoDoc
	override Obj? toJsonVal(Obj? fantomObj, JsonConverterCtx ctx) {
		if (fantomObj == null) return null
		jsonObj := ctx.fnMakeJsonObj
		
		ctx.optJsonPropertyCache.getOrFindTags(fantomObj.typeof, ctx).each |field| {
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

		// because ObjConverter is a catch-all Obj converter, we sometimes get sent here when a specific converter can't be found
		// in which case, the sanity check below throws a really good err msg which should be understood by the user
		// so no real need for the extra procoessing here 
//		if (jsonVal isnot Map && !ReflectUtils.fits(jsonVal.typeof, fantomType))
//			throw Err(documentConv_noConverter(fantomType, jsonVal))

		// we get sent to ObjConverter when the field type is 'Obj?' - so just return the JSON literal
		if (jsonVal isnot Map)
			return jsonVal

		jsonObj		:= (Str:Obj?) jsonVal
		fieldVals	:= [Field:Obj?][:]

		if (jsonObj.containsKey("_type"))
			// we *should* set _type if we can, it's expected behaviour and there's no reason not to
			ctx.replaceType(Type.find(jsonObj.get("_type")))	
			
		tagData := ctx.optJsonPropertyCache.getOrFindTags(ctx.type, ctx)
		
		if (ctx.optStrictMode) {
			tagNames := tagData.map { it.name }
			keyNames := jsonObj.keys
			keyNames = keyNames.removeAll(tagNames)
			if (keyNames.size > 0)
				throw Err("Extraneous data in JSON object for ${ctx.type.qname}: " + keyNames.join(", "))
		}

		// we can't instantiate 'Obj' so just return wot we got
		// this is important to LspRpc testing - and just makes sense
		// I mean, why should we throw an error when we already have an obj?
		if (ctx.type.toNonNullable == Obj#)
			return jsonVal
		
		// for-loop to cut down on func obj creation
		for (i := 0; i < tagData.size; ++i) {
			field	 := tagData[i]
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

			if (field.field.isConst)	// todo I should test this! Needed when we inject Maps into const fields (in a non-const object)
				fieldVal = fieldVal.toImmutable
			fieldVals[field.field] = fieldVal
		}
		
		return ctx.fnMakeEntity(fieldVals)
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
		stripSys("JSON property ${propName} is null but field ${field.qname} is NOT nullable : ${document}")
	}

	private static Str documentConv_propertyNotFound(Field field, Str:Obj? document) {
		stripSys("JSON property does not contain a property for field ${field.qname} : ${document}")
	}
	
	private static Str documentConv_propertyDoesNotFitField(Str propName, Type propType, Field field, Str:Obj? document) {
		stripSys("JSON property ${propName} of type ${propType.signature} does not fit field ${field.qname} of type ${field.type.signature} : ${document}")
	}

	private static Str stripSys(Str str) {
		str.replace("sys::", "")
	}
}
