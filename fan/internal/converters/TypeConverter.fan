
** See [Type does not conform to @Serializable rules]`http://fantom.org/forum/topic/2504`
@Js
internal const class TypeConverter : JsonConverter {

	override Obj? toJson(JsonConverterCtx ctx, Obj? fantomObj) {
		if (fantomObj == null) return null
		return ((Type) fantomObj).qname
	}

	override Obj? toFantom(JsonConverterCtx ctx, Obj? jsonObj) {
		if (jsonObj == null) return null
		return Type.find((Str) jsonObj)
	}
}
