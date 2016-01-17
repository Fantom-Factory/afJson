//using afBeanUtils::TypeCoercer
//using afBeanUtils::BeanFactory
//
//@NoDoc
//const class MapConverter : JsonConverter {
//
//	private const TypeCoercer		typeCoercer
//	private static const Regex		unicodeRegex	:= "\\\\u+[0-9a-fA-F]{4}".toRegex
//	private static const Regex		unicodeRegex2	:= "\\\\u{2,}[0-9a-fA-F]{4}".toRegex
//	
//	new make(|This|in) {
//		in(this)
//		this.typeCoercer = CachingTypeCoercer()
//	}	
//	
//	override Obj? toJson(JsonConverterCtx ctx, Obj? fantomObj) {
//		if (fantomObj == null) return null
//		fanMap		:= (Map) fantomObj
//		mapType		:= fanMap.typeof
//		
//		// if the whole map is a valid BSON document, then just encode the keys
//		if (!mapType.isGeneric) {
//			keyType 	:= mapType.params["K"]
//			valType 	:= mapType.params["V"]
//			if (keyType == Str# && BsonType.isBsonLiteral(valType)) {
//				mongoMap	:= emptyDoc
//				fanMap.each |fVal, fKey| {
//					mongoMap[encodeKey(fKey)] = fVal
//				}
//				return mongoMap
//			}
//		}
//		
//		mongoMap	:= emptyDoc
//		fanMap.each |fVal, fKey| {
//			// Map keys are special and have to be converted <=> Str
//			// As *anything* can be converter toStr(), let's check up front that we can convert it back to Fantom again!
//			if (!typeCoercer.canCoerce(Str#, fKey.typeof))
//				throw MorphiaErr(ErrMsgs.mapConverter_cannotCoerceKey(fKey.typeof))
//			
//			// encode map keys to handle the special '.' and '$' chars
//			mKey := encodeKey(typeCoercer.coerce(fKey, Str#))
//			mVal := fVal == null ? null : converters().toMongo(fVal.typeof, fVal)
//			mongoMap[mKey] = mVal
//		}		
//		return mongoMap
//	}
//	
//	override Obj? toFantom(JsonConverterCtx ctx, Obj? jsonObj) {
//		if (mongoObj == null) return null
//
//		fanKeyType 	:= fanMapType.params["K"]
//		fanValType 	:= fanMapType.params["V"]
//
//		mongoMapRaw	:= (Map) mongoObj
//		monMapType	:= mongoMapRaw.typeof
//		monValType 	:= monMapType.params["V"]
//		
//		// monKeyType should always be Str#
//		mongoMap	:= makeMap(Map#.parameterize(["K":Str#, "V":monValType]))
//		mongoMapRaw.each |v, k| {
//			mongoMap[decodeKey(k.toStr)] = v
//		}
//		
//		if (fanKeyType == Str#) {
//			if (monValType.fits(fanValType))
//				return mongoMap
//
//			fanMap := makeMap(fanMapType)
//			if (BsonType.isBsonLiteral(fanValType)) {
//				// if the Fantom val type is BSON, just copy the vals over 'cos they wouldn't have changed
//				fanMap.addAll(mongoMap)
//
//			} else {
//				// keep the keys, just convert the vals
//				mongoMap.each |mVal, mKey| {
//					fanMap[mKey] = converters().toFantom(fanValType, mVal)
//				}				
//			}
//			return fanMap
//		}
//		
//		fanMap		:= makeMap(fanMapType)
//		mongoMap.each |mVal, mKey| {
//			// Map keys are special and have to be converted <=> Str
//			fKey := typeCoercer.coerce(decodeKey(mKey), fanKeyType)
//			fVal := converters().toFantom(fanValType, mVal)
//			fanMap[fKey] = fVal
//		}
//		return fanMap
//	}
//	
//	** Creates an empty *ordered* Mongo document. 
//	** 
//	** Override for different behaviour. 
//	virtual Str:Obj? emptyDoc() {
//		Str:Obj?[:] { ordered = true }
//	}
//
//	** Creates an empty map for Fantom. Always creates an ordered map.
//	** 
//	** Override for different behaviour. 
//	virtual Obj:Obj? makeMap(Type mapType) {
//		((Map) BeanFactory.defaultValue(mapType, true)) {
//			it.ordered = true
//		}
//	}
//	
//	// http://stackoverflow.com/questions/21522770/unicode-escape-syntax-in-java
//	internal static Str encodeKey(Str key) {
//		buf		:= StrBuf(key.size + 5).add(key)
//		matcher := unicodeRegex.matcher(key)
//		idx		:= 0
//		while (matcher.find) {
//			buf.insert(matcher.start(0) + 1 + idx++, "u")
//		}
//		return buf.toStr.replace("\$", "\\u0024").replace(".", "\\u002e")
//	}
//	internal static Str decodeKey(Str key) {
//		replace	:= key.replace("\\u002e", ".").replace("\\u0024", "\$")
//		buf		:= StrBuf(replace.size).add(replace)
//		matcher := unicodeRegex2.matcher(replace)
//		idx		:= 0
//		while (matcher.find) {
//			buf.remove(matcher.start(0) + 1 + idx--)
//		}
//		return buf.toStr
//	}
//}
