
** (Service) - 
** The main JSON converter class.
const mixin JsonConverters {
	
	static new makeDefault() {
		make([
			LiteralInspector(),
			SimpleInspector(Date#, DateConverter()),
			SimpleInspector(Enum#, EnumConverter()),
//			SimpleInspector(List#, ListConverter()),
//			SimpleInspector(Map#, MapConverter()),
			SimpleInspector(Slot#, SlotConverter()),
			SimpleInspector(Type#, TypeConverter()),
			ObjInspector()
		])			
	}

	static new make(JsonInspector[] inspectors) {
		JsonConvertersImpl(JsonInspectorsImpl(inspectors))
	}

	abstract Obj? toJson(Type fantomType, Obj? fantomObj)
	
	abstract Obj? toFantom(Type fantomType, Obj? jsonObj)	
}

internal const class JsonConvertersImpl : JsonConverters {
	private const JsonInspectors	inspectors
	

	
	new makeIoc(JsonInspectors inspectors) {
		this.inspectors	= inspectors
	}
	
	override Obj? toJson(Type fantomType, Obj? fantomObj) {
		meta := inspectors.inspect(fantomType)
		ctx  := JsonConverterCtxImpl {
			it.metaStack	= JsonConverterMeta[meta]
			it.fantomStack	= Obj?[,]
		}
		return meta.converter.toJson(ctx, fantomObj)
	}
	
	override Obj? toFantom(Type fantomType, Obj? jsonObj) {
		meta := inspectors.inspect(fantomType)
		ctx  := JsonConverterCtxImpl {
			it.metaStack	= JsonConverterMeta[meta]
			it.jsonStack	= Obj?[,]
		}
		return meta.converter.toFantom(ctx, jsonObj)
	}
}
