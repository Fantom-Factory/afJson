
@Js internal const class JsonListConverter : JsonConverter {
	
	override Obj? toJsonVal(Obj? fantomObj, JsonConverterCtx ctx) {
		if (fantomObj == null) return null

		fanList	 := (List) fantomObj
		listType := fanList.typeof
		
		return fanList.map |obj, idx| {
			obj == null
				? null
				: ctx.makeList(obj?.typeof ?: fanList.of, fanList, idx, obj).toJsonVal
		}
	}
	
	override Obj? fromJsonVal(Obj? jsonVal, JsonConverterCtx ctx) {
		if (jsonVal == null) return null

		fanValType	:= ctx.type.params["V"]
		jsonList	:= (List) jsonVal
		folListType	:= jsonList.typeof
		folValType	:= folListType.params["V"]
		
		// if the whole list is of the same type, return it as is
		if (folValType.fits(fanValType))
			return jsonList
		
		fanList		:= List(fanValType, jsonList.size)

		// for-loop to cut down on func obj creation
		for (idx := 0; idx < jsonList.size; ++idx) {
			obj := jsonList[idx]
			fan := ctx.makeList(fanValType, jsonList, idx, obj).fromJsonVal
			fanList.add(fan)
		}

		return fanList
	}
}
