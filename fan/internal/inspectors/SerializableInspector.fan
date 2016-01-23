
internal const class SerializableInspector : JsonTypeInspector {
	
	override JsonTypeMeta? inspect(Type type, JsonInspectors inspectors) {
		serializable := (Serializable?) type.facet(Serializable#, false)
		if (serializable == null || serializable.simple.not)
			return null

		return JsonTypeMeta {
			it.type			= type
			it.converter	= SimpleConveter(type)
		}
	}
}