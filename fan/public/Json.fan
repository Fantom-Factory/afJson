
** A one-stop shop for all your JSON needs!
const class Json {
	
	private const JsonInspectors	inspectors
	private const JsonConverters	converters
	
	new make() {
		converters = JsonConverters()
		inspectors = JsonInspectors()
	}
	
	private new makeWithIoc(JsonConverters converters, JsonInspectors inspectors) {
		this.converters = converters
		this.inspectors = inspectors
	}
	
	** Convenience for:
	** 
	**   syntax: fantom
	**   JsonConverters().toJson(...)
	Obj? toJson(Obj? fantomObj, Type? fantomType := null, JsonConverterMeta? meta := null) {
		converters.toJson(fantomObj, fantomType ?: fantomObj.typeof, meta)
	}
	
	** Convenience for:
	** 
	**   syntax: fantom
	**   JsonConverters().toFantom(...)
	Obj? toFantom(Obj? jsonObj, Type fantomType, JsonConverterMeta? meta := null) {
		converters.toFantom(jsonObj, fantomType, meta)
	}

	JsonConverterMeta getOrInspectTypeMeta(Type type) {
		inspectors.getOrInspect(type)
	}

	Void setTypeMeta(Type type, JsonConverterMeta meta) {
		inspectors.set(type, meta)
	}
}
