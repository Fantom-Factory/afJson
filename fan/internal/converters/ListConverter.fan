
internal const class ListConverter : JsonConverter {

	override Obj? toJson(JsonConverterCtx ctx, Obj? fantomObj) {
		if (fantomObj == null) return null

		fanList	 := (List) fantomObj
		listType := fanList.typeof
		
		// if the whole list is a valid JSON document, then return it as is
		if (!listType.isGeneric)
			if (JsonType.isLiteral(listType) || fanList.all { JsonType.isLiteral(it?.typeof) })
				return fantomObj
		
		return fanList.map {
			it == null ? null : ctx.toJson(ctx.inspect(it.typeof), it) 
		}
	}

	override Obj? toFantom(JsonConverterCtx ctx, Obj? jsonObj) {
		if (jsonObj == null) return null

		fanValType	:= ctx.meta.type.params["V"] ?: Obj?#
		jsonList	:= (List) jsonObj
		jsonListType:= jsonList.typeof
		jsonValType	:= jsonListType.params["V"] ?: Obj?#
	
		// if the whole list is a valid JSON document, then return it as is
		if (jsonValType.fits(fanValType))
			return jsonList
		
		fanList		:= List(fanValType, jsonList.size)
		if (JsonType.isLiteral(fanValType))
			fanList.addAll(jsonList)
		else
			fanList.addAll(jsonList.map { ctx.toFantom(ctx.inspect(fanValType), it) })

		return fanList
	}
}
