
internal const class NamedInspector : JsonTypeInspector {
	private const Type type
	private const JsonConverter	converter

	new make(Type type, JsonConverter converter) {
		this.type		= type
		this.converter	= converter
	}
	
	override JsonTypeMeta? inspect(Type type, JsonInspectors inspectors) {
		return this.type != type && this.type.name != type.name
			? null
			: JsonTypeMeta {
				it.type			= this.type
				it.converter	= this.converter
			}
	}
}