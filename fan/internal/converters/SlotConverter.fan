
internal const class SlotConverter : JsonConverter {

	override Obj? toJson(JsonConverterCtx ctx, Obj? fantomObj) {
		if (fantomObj == null) return null
		return ((Slot) fantomObj).qname
	}

	override Obj? toFantom(JsonConverterCtx ctx, Obj? jsonObj) {
		if (jsonObj == null) return null
		return Slot.find((Str) jsonObj)
	}
}