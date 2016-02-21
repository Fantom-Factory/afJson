using afConcurrent::AtomicMap

// We need JsonInspectors if only to have an IoC service to contribute Inspectors too!
** (Service) - Holds a list of 'JsonTypeInspector' instances and the cached 'JsonTypeMeta' objects.
const mixin JsonTypeInspectors {

	** Creates an instance of 'JsonTypeInspectors' with the given inspectors.
	static new make(JsonTypeInspector[] inspectors := defaultInspectors) {
		JsonTypeInspectorsImpl(inspectors)
	}

	** The default list of inspectors.
	static JsonTypeInspector[] defaultInspectors() {
		[
			LiteralInspector(),
			NamedInspector(Map#, 	MapConverter()),
			NamedInspector(List#,	ListConverter()),
			NamedInspector(Type#,	TypeConverter()),
			NamedInspector(Slot#,	SlotConverter()),
			NamedInspector(Method#,	SlotConverter()),
			NamedInspector(Field#,	SlotConverter()),
			SerializableInspector(),
			ObjInspector()
		]
	}
	
	** Returns and caches 'JsonTypeMeta' associated with the given type.
	@Operator
	abstract JsonTypeMeta getOrInspect(Type type)

	** Sets 'JsonTypeMeta' to be associated with the given type.
	@Operator
	abstract Void set(Type type, JsonTypeMeta meta)
	
	** Converts the given entity to its JSON representation.
	** 
	** If 'fantomType' is 'null' it defaults to 'fantomObj.typeof()'.
	** 
	** If 'meta' is 'null' then a cached version for 'fantomType' is retrieved from 'JsonTypeInspectors'.
	abstract Obj? toJson(Obj? fantomObj, Type? fantomType := null, JsonTypeMeta? meta := null)
	
	** Converts the given 'jsonObj' to its Fantom representation.
	** 	
	** If 'meta' is 'null' then a cached version for 'fantomType' is retrieved from 'JsonTypeInspectors'.
	abstract Obj? toFantom(Obj? jsonObj, Type fantomType, JsonTypeMeta? meta := null)

}

internal const class JsonTypeInspectorsImpl : JsonTypeInspectors {
	private const AtomicMap				metaObjs	:= AtomicMap { it.keyType=Type#; it.valType=JsonTypeMeta# }
	private const JsonTypeInspector[] 	inspectors
	
	new make(JsonTypeInspector[] inspectors) {
		this.inspectors = inspectors
	}

	override JsonTypeMeta getOrInspect(Type type) {
		metaObjs.getOrAdd(type) { 
			inspectors.eachWhile { it.inspect(type, this) } ?: Err("Could not find Inspector to process ${type.qname}")
		}
	}
	
	override Void set(Type type, JsonTypeMeta meta) {
		metaObjs[type] = meta
	}
	
	override Obj? toJson(Obj? fantomObj, Type? fantomType := null, JsonTypeMeta? meta := null) {
		meta = meta ?: getOrInspect(fantomType ?: fantomObj.typeof)
		ctx  := JsonConverterCtxImpl {
			it.inspectors	= this
			it.metaStack	= JsonTypeMeta[meta]
			it.fantomStack	= Obj?[,]
		}
		return meta.converter.toJson(ctx, fantomObj)
	}
	
	override Obj? toFantom(Obj? jsonObj, Type fantomType, JsonTypeMeta? meta := null) {
		meta = meta ?: getOrInspect(fantomType)
		ctx  := JsonConverterCtxImpl {
			it.inspectors	= this
			it.metaStack	= JsonTypeMeta[meta]
			it.jsonStack	= Obj?[,]
		}
		return meta.converter.toFantom(ctx, jsonObj)
	}
}
