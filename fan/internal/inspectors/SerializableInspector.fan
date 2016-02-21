using afConcurrent::AtomicMap

** Inspects objects annotated with '@Serializable { simple = true }'.
internal const class SerializableInspector : JsonTypeInspector {
	private const AtomicMap	converters	:= AtomicMap { it.keyType=Type#; it.valType=SerializableConveter# }

	override JsonTypeMeta? inspect(Type type, JsonTypeInspectors inspectors) {
		serializable := (Serializable?) type.facet(Serializable#, false)
		if (serializable == null || serializable.simple.not)
			return null

		return JsonTypeMeta {
			it.type			= type
			it.converter	= this.converters.getOrAdd(type) { SerializableConveter(type) }
		}
	}
}