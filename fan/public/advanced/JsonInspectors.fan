using afConcurrent

//@NoDoc	// Advanced use only!
** (Service) - 
const mixin JsonInspectors {

	static new makeDefault() {
		JsonInspectorsImpl([
			LiteralInspector(),
			NamedInspector(Map#, 	MapConverter()),
			NamedInspector(List#,	ListConverter()),
			NamedInspector(Type#,	TypeConverter()),
			NamedInspector(Slot#,	SlotConverter()),
			NamedInspector(Method#,	SlotConverter()),
			NamedInspector(Field#,	SlotConverter()),
			SerializableInspector(),
			ObjInspector()
		])
	}

	static new make(JsonInspector[] inspectors) {
		JsonInspectorsImpl(inspectors)
	}
	
	@Operator
	abstract JsonConverterMeta getOrInspect(Type type)

	@Operator
	abstract Void set(Type type, JsonConverterMeta meta)
}

internal const class JsonInspectorsImpl : JsonInspectors {
	private const AtomicMap			metaObjs	:= AtomicMap { it.keyType=Type#; it.valType=JsonConverterMeta# }
	private const JsonInspector[] 	jsonInspectors
	
	new make(JsonInspector[] jsonInspectors) {
		this.jsonInspectors = jsonInspectors
	}

	override JsonConverterMeta getOrInspect(Type type) {
		metaObjs.getOrAdd(type) { 
			jsonInspectors.eachWhile { it.inspect(type, this) } ?: Err("Could not find Inspector to process ${type.qname}")
		}
	}
	
	override Void set(Type type, JsonConverterMeta meta) {
		metaObjs[type] = meta
	}
}
