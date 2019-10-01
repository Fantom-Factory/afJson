
@Js internal const class JsonSlotConverter : JsonConverter {
	
	override Obj? toJsonVal(Obj? fantomObj, JsonConverterCtx ctx) {
		if (fantomObj == null) return null
		return ((Slot) fantomObj).qname
	}

	override Obj? fromJsonVal(Obj? jsonVal, JsonConverterCtx ctx) {
		if (jsonVal == null) return null
		return Slot.find((Str) jsonVal)
	}
}
