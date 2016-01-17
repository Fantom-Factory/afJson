
//@NoDoc
//const class ListConverter : JsonConverter {
//
//	new make(|This|in) {
//		in(this)
//	}
//	
//	override Obj? toJson(JsonConverterCtx ctx, Obj? fantomObj) {
//		if (fantomObj == null) return null
//
//		fanList	 := (List) fantomObj
//		listType := fanList.typeof
//		
//		// if the whole list is a valid BSON document, then return it as is
//		if (!listType.isGeneric)
//			if (JsonType.isLiteral(listType) || fanList.all { JsonType.isLiteral(it?.typeof) })
//				return fantomObj
//		
//		
//		return ((List) fantomObj).map { it == null ? null : converters().fromFantom(it.typeof, it) }
//	}
//
//	override Obj? toFantom(JsonConverterCtx ctx, Obj? jsonObj) {
//		if (jsonObj == null) return null
//
//		fanValType	:= ctx.fantomType.params["V"]
//		jsonList	:= (List) jsonObj
//		jsonListType:= jsonList.typeof
//		jsonValType	:= jsonListType.params["V"]
//	
//		// if the whole list is a valid JSON document, then return it as is
//		if (jsonValType.fits(fanValType))
//			return jsonList
//		
//		fanList		:= List(fanValType, jsonList.size)
//		if (JsonType.isLiteral(fanValType))
//			fanList.addAll(jsonList)
//		else
//			fanList.addAll(jsonList.map { converters().toFantom(fanValType, it) })
//
//		return fanList
//	}
//}
