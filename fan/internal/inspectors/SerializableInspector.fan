
internal const class SerializableInspector : JsonInspector {
	
	override JsonConverterMeta? inspect(Type type, JsonInspectors inspectors) {
		serializable := (Serializable?) type.facet(Serializable#, false)
		if (serializable == null || serializable.simple.not)
			return null

		return JsonConverterMeta {
			it.type			= type
			it.converter	= SimpleConveter(type)
		}
	}
}