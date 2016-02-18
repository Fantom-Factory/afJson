using afConcurrent::AtomicMap

internal const class SerializableInspector : JsonTypeInspector {
	private const AtomicMap	converters	:= AtomicMap { it.keyType=Type#; it.valType=SimpleConveter# }

	override JsonTypeMeta? inspect(Type type, JsonTypeInspectors inspectors) {
		serializable := (Serializable?) type.facet(Serializable#, false)
		if (serializable == null || serializable.simple.not)
			return null

		return JsonTypeMeta {
			it.type			= type
			it.converter	= this.converters.getOrAdd(type) { SimpleConveter(type) }
		}
	}
}