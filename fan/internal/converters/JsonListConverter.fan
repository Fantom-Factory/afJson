
@Js internal const class JsonListConverter : JsonConverter {
	
	private const Type[] jsonTypes	:= Type[Str#, Float#, Bool#]
	
	override Obj? toJsonVal(Obj? fantomObj, JsonConverterCtx ctx) {
		if (fantomObj == null) return null

		fanList	 := (List) fantomObj
		listType := fanList.typeof
		
		// if the whole list is of the same JSON type, return it as is
		if (jsonTypes.contains(fanList.of))
			return fanList

		return fanList.map |obj, idx| {
			obj == null
				? null
				: ctx.makeList(obj?.typeof ?: fanList.of, fanList, idx, obj).toJsonVal
		}
	}
	
	override Obj? fromJsonVal(Obj? jsonVal, JsonConverterCtx ctx) {
		if (jsonVal == null) return null

		fanValType	:= ctx.type.params["V"]
		folListType	:= jsonVal.typeof
		folValType	:= folListType.params["V"]
		
		// if the whole list is of the same type, return it as is
		// but make sure we still convert Objs
		if (folValType.toNonNullable != Obj# && folValType.fits(fanValType))
			return jsonVal
		
		// the cast to (Obj?[]) is NEEDED!
		// see Nullable Generic Lists - https://fantom.org/forum/topic/2777
		jsonList	:= (List) jsonVal
		fanList		:= (Obj?[]) List(fanValType, jsonList.size)

		// for-loop to cut down on func obj creation
		for (idx := 0; idx < jsonList.size; ++idx) {
			obj := jsonList[idx]
			fan := ctx.makeList(fanValType, jsonList, idx, obj).fromJsonVal
			fanList.add(fan)
		}

		return fanList
	}
}
