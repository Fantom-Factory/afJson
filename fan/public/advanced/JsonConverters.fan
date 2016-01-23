
** (Service) - 
** The main JSON converter class.
const mixin JsonConverters {
	
	static new makeDefault() {
		JsonConvertersImpl(JsonInspectors())
	}

	static new make(JsonInspectors inspectors) {
		JsonConvertersImpl(inspectors)
	}

	** If 'fantomType' is 'null' it defaults to 'fantomObj.typeof()'. 
	abstract Obj? toJson(Obj? fantomObj, Type? fantomType := null, JsonConverterMeta? meta := null)
	
	abstract Obj? toFantom(Obj? jsonObj, Type fantomType, JsonConverterMeta? meta := null)	
}

internal const class JsonConvertersImpl : JsonConverters {
	private const JsonInspectors	inspectors
	
	new make(JsonInspectors inspectors) {
		this.inspectors	= inspectors
	}
	
	override Obj? toJson(Obj? fantomObj, Type? fantomType := null, JsonConverterMeta? meta := null) {
		meta = meta ?: inspectors.getOrInspect(fantomType ?: fantomObj.typeof)
		ctx  := JsonConverterCtxImpl {
			it.inspectors	= this.inspectors
			it.metaStack	= JsonConverterMeta[meta]
			it.fantomStack	= Obj?[,]
		}
		return meta.converter.toJson(ctx, fantomObj)
	}
	
	override Obj? toFantom(Obj? jsonObj, Type fantomType, JsonConverterMeta? meta := null) {
		meta = meta ?: inspectors.getOrInspect(fantomType)
		ctx  := JsonConverterCtxImpl {
			it.inspectors	= this.inspectors
			it.metaStack	= JsonConverterMeta[meta]
			it.jsonStack	= Obj?[,]
		}
		return meta.converter.toFantom(ctx, jsonObj)
	}
}
