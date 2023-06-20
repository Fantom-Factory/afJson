
@Js internal const class JsonUriConverter : JsonConverter {
	
	override Obj? toJsonVal(Obj? fantomObj, JsonConverterCtx ctx) {
		if (fantomObj == null) return null
		return ctx.optEncodeDecodeUris
			? ((Uri) fantomObj).encode
			: ((Uri) fantomObj).toStr
	}

	override Obj? fromJsonVal(Obj? jsonVal, JsonConverterCtx ctx) {
		if (jsonVal == null) return null
		return ctx.optEncodeDecodeUris
			? Uri.decode(jsonVal)
			: Uri.fromStr(jsonVal)
	}
}
