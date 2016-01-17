
internal const class LiteralInspector : JsonInspector {

	override JsonConverterMeta? inspect(Type type, JsonInspectors inspectors) {
		return JsonType.isLiteral(type).not
			? null
			: JsonConverterMeta {
				it.type			= type
				it.converter	= LiteralConverter()
			}
	}
}