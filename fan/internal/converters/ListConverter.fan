
** Lists need to be defined as specific, non-generic, types, e.g. Int[]
** Otherwise we don't know how to convert!
@Js
internal const class ListConverter : JsonConverter {

	override Obj? toJsonObj(JsonConverterCtx ctx, Obj? fantomObj) {
		if (fantomObj == null) return null

		fanList	 := (List) fantomObj
		listType := fanList.typeof
		
		// if the list only contains JSON literals that require no conversion, then return it as is
		if (!listType.isGeneric)
			if (requiresNoConversion(ctx, listType) || fanList.all { requiresNoConversion(ctx, it?.typeof) })
				return fantomObj
		
		return fanList.map {
			it == null ? null : ctx.toJson(ctx.inspect(it.typeof), it) 
		}
	}

	override Obj? toFantom(JsonConverterCtx ctx, Obj? jsonObj) {
		if (jsonObj == null) return null

		fanValType	:= (ctx.meta.implType ?: ctx.meta.type).params["V"] ?: Obj?#
		jsonList	:= (List) jsonObj
		jsonListType:= jsonList.typeof
		jsonValType	:= jsonListType.params["V"] ?: Obj?#
	
		// if the list requires no conversion, then return it as is
		if (jsonValType.fits(fanValType) && requiresNoConversion(ctx, fanValType))
			return jsonList
		
		// the given JSON list may have been Obj?[], hence wouldn't have fit fanValType
		fanList	:= List(fanValType, jsonList.size)
		if (requiresNoConversion(ctx, fanValType))
			fanList.addAll(jsonList)
		else
			fanList.addAll(jsonList.map { ctx.toFantom(ctx.inspect(fanValType), it) })

		return fanList
	}
	
	** For JSON literal checks, ensure the default converter has not been overridden 
	private static Bool requiresNoConversion(JsonConverterCtx ctx, Type? type) {
		type == null || ctx.inspect(type).converter is LiteralConverter
	}
}
