
internal const class NamedInspector : JsonInspector {
	private const Type type
	private const JsonConverter	converter

	new make(Type type, JsonConverter converter) {
		this.type		= type
		this.converter	= converter
	}
	
	override JsonConverterMeta? inspect(Type type, JsonInspectors inspectors) {
		return this.type != type && this.type.name != type.name
			? null
			: JsonConverterMeta {
				it.type			= this.type
				it.converter	= this.converter
			}
	}
}