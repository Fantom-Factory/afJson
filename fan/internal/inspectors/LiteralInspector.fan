
internal const class LiteralInspector : JsonTypeInspector {

	const JsonConverter converter	:= LiteralConverter()

	new make(|This|? in := null) { in?.call(this) }
	
	override JsonTypeMeta? inspect(Type type, JsonTypeInspectors inspectors) {
		return JsonType.isLiteral(type)
			? JsonTypeMeta {
				it.type			= type
				it.converter	= this.converter
			}
			: null
	}
}