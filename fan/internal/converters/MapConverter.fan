using afBeanUtils::TypeCoercer
using afBeanUtils::BeanFactory

** Maps need to be defined as specific, non-generic, types, e.g. Str:Int[]
** Otherwise we don't know how to convert!
@Js @NoDoc
const class MapConverter : JsonConverter {
	private const TypeCoercer	typeCoercer	:= CachingTypeCoercer()
	
	override Obj? toJsonObj(JsonConverterCtx ctx, Obj? fantomObj) {
		if (fantomObj == null) return null

		// the field declaration is more likely to have params than the actual object
		// plus it mirrors what 'toFantom()' does
		mapType		:= ctx.meta.type
		fanMap		:= (Map) fantomObj
		
		// if the map only contains JSON literals that require no conversion, then return it as is
		if (!mapType.isGeneric) {
			keyType 	:= mapType.params["K"] ?: Obj?#
			valType 	:= mapType.params["V"] ?: Obj?#
			if (keyType == Str# && requiresNoConversion(ctx, valType))
				return fantomObj
		}
		
		jsonMap	:= emptyDoc
		fanMap.each |fVal, fKey| {
			// Map keys are special and have to be converted <=> Str
			// As *anything* can be converter toStr(), let's check up front that we can convert it back to Fantom again!
			
			// Actually, lets not - too much processing overhead for little value 
//			if (!typeCoercer.canCoerce(Str#, fKey.typeof))
//				throw Err(ErrMsgs.mapConverter_cannotCoerceKey(fKey.typeof))
			
			// converters are for converting JSON values, hence we've chosen to use simple coercion for map keys 
			mKey := typeCoercer.coerce(fKey, Str#)
			mVal := fVal == null ? null : ctx.toJson(ctx.inspect(fVal.typeof), fVal)
			jsonMap[mKey] = mVal
		}		
		return jsonMap
	}
	
	override Obj? toFantom(JsonConverterCtx ctx, Obj? jsonObj) {
		if (jsonObj == null) return null

		fanMapType	:= ctx.meta.implType ?: ctx.meta.type
		fanKeyType 	:= fanMapType.params["K"] ?: Obj?#
		fanValType 	:= fanMapType.params["V"] ?: Obj?#

		jsonMap		:= (Map) jsonObj
		jsonMapType	:= jsonMap.typeof
		jsonValType	:= jsonMapType.params["V"] ?: Obj?#
		
		if (fanKeyType == Str#) {
			if (jsonValType.fits(fanValType) || requiresNoConversion(ctx, fanValType))
				return jsonMap

			fanMap := makeMap(fanMapType)
			// keep the keys, just convert the vals
			jsonMap.each |jVal, jKey| {
				meta := ctx.inspect(fanValType)
				fanMap[jKey] = ctx.toFantom(meta, jVal)
			}				
			return fanMap
		}
		
		fanMap := makeMap(fanMapType)
		jsonMap.each |jVal, jKey| {
			// Map keys are special and have to be coerced <=> Str
			fKey := typeCoercer.coerce(jKey, fanKeyType)
			fVal := ctx.toFantom(ctx.inspect(fanValType), jVal)
			fanMap[fKey] = fVal
		}
		return fanMap
	}
	
	** Creates an empty *ordered* JSON map.
	** 
	** Override if you prefer your JSON maps unordered or case-insensitive.
	virtual Str:Obj? emptyDoc() {
		Str:Obj?[:] { ordered = true }
	}

	** Creates an empty map for Fantom. Always creates an ordered map.
	** 
	** Override if you prefer your maps unordered or case-insensitive.
	virtual Obj:Obj? makeMap(Type mapType) {
		((Map) BeanFactory.defaultValue(mapType, true)) {
			it.ordered = true
		}
	}
	
	** For JSON literal checks, ensure the default converter has not been overridden 
	private static Bool requiresNoConversion(JsonConverterCtx ctx, Type? type) {
		type == null || ctx.inspect(type).converter is LiteralConverter
	}
}
