using afBeanUtils::TypeCoercer

@Js internal const class JsonMapConverter : JsonConverter {
	private const TypeCoercer	typeCoercer
	
	new make() {
		this.typeCoercer = CachingTypeCoercer()
	}

	override Obj? toJsonVal(Obj? fantomObj, JsonConverterCtx ctx) {
		if (fantomObj == null) return null
		fanMap		:= (Map) fantomObj
		mapType		:= fanMap.typeof
		jsonObj		:= ctx.fnMakeJsonObj
		fanMap.each |fVal, fKey| {
			// Map keys are special and have to be converted <=> Str
			// As *anything* can be converter toStr(), let's check up front that we can convert it back to Fantom again!
			if (!typeCoercer.canCoerce(Str#, fKey.typeof))
				throw Err("Unsupported Map key type '${fKey.typeof.qname}', cannot coerce from Str#")
			
			mKey := typeCoercer.coerce(fKey, Str#)
			mVal := fVal == null ? null : ctx.makeMap(fVal.typeof, fanMap, fKey, fVal).toJsonVal
			jsonObj[mKey] = mVal
		}		
		return jsonObj
	}
	
	override Obj? fromJsonVal(Obj? jsonVal, JsonConverterCtx ctx) {
		if (jsonVal == null) return null

		fanKeyType 	:= ctx.type.params["K"]
		fanValType 	:= ctx.type.params["V"]

		jsonObj		:= (Str:Obj?) jsonVal
		fanMap		:= ctx.fnMakeMap
		jsonObj.each |jVal, jKey| {
			// Map keys are special and have to be converted <=> Str
			fKey := typeCoercer.coerce(jKey, fanKeyType)
			fVal := ctx.makeMap(fanValType, jsonObj, jKey, jVal).fromJsonVal
			fanMap[fKey] = fVal
		}
		return fanMap
	}
}
