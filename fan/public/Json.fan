
** (Service) - 
** A one-stop shop for all your JSON needs!
const mixin Json {
	
	static new make() {
		JsonImpl(JsonTypeInspectors())
	}
	
	** If 'fantomType' is 'null' it defaults to 'fantomObj.typeof()'. 
	abstract Obj? toJson(Obj? fantomObj, Type? fantomType := null, JsonTypeMeta? meta := null)
	
	abstract Obj? toFantom(Obj? jsonObj, Type fantomType, JsonTypeMeta? meta := null)

	abstract JsonTypeMeta getOrInspectTypeMeta(Type type)

	abstract Void setTypeMeta(Type type, JsonTypeMeta meta)
}

internal const class JsonImpl : Json {	
	private const JsonTypeInspectors	inspectors
	
	new makeWithIoc(JsonTypeInspectors inspectors) {
		this.inspectors = inspectors
	}
	
	override Obj? toJson(Obj? fantomObj, Type? fantomType := null, JsonTypeMeta? meta := null) {
		meta = meta ?: inspectors.getOrInspect(fantomType ?: fantomObj.typeof)
		ctx  := JsonConverterCtxImpl {
			it.inspectors	= this.inspectors
			it.metaStack	= JsonTypeMeta[meta]
			it.fantomStack	= Obj?[,]
		}
		return meta.converter.toJson(ctx, fantomObj)
	}
	
	override Obj? toFantom(Obj? jsonObj, Type fantomType, JsonTypeMeta? meta := null) {
		meta = meta ?: inspectors.getOrInspect(fantomType)
		ctx  := JsonConverterCtxImpl {
			it.inspectors	= this.inspectors
			it.metaStack	= JsonTypeMeta[meta]
			it.jsonStack	= Obj?[,]
		}
		return meta.converter.toFantom(ctx, jsonObj)
	}

	override JsonTypeMeta getOrInspectTypeMeta(Type type) {
		inspectors.getOrInspect(type)
	}

	override Void setTypeMeta(Type type, JsonTypeMeta meta) {
		inspectors.set(type, meta)
	}
}
