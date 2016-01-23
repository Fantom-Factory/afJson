
internal const class LiteralInspector : JsonTypeInspector {

	override JsonTypeMeta? inspect(Type type, JsonInspectors inspectors) {
		return JsonType.isLiteral(type).not
			? null
			: JsonTypeMeta {
				it.type			= type
				it.converter	= LiteralConverter()
			}
	}
}