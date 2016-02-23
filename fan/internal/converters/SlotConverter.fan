
** See [Slot does not conform to @Serializable rules]`http://fantom.org/forum/topic/2504`
@Js
internal const class SlotConverter : JsonConverter {

	override Obj? toJsonObj(JsonConverterCtx ctx, Obj? fantomObj) {
		if (fantomObj == null) return null
		return ((Slot) fantomObj).qname
	}

	override Obj? toFantom(JsonConverterCtx ctx, Obj? jsonObj) {
		if (jsonObj == null) return null
		return Slot.find((Str) jsonObj)
	}
}
