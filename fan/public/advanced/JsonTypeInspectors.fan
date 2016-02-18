using afConcurrent::AtomicMap

// We need JsonInspectors if only to have an IoC service to contribute Inspectors too!
** (Service) - 
@NoDoc	// Advanced use only!
const mixin JsonTypeInspectors {

	static new make(JsonTypeInspector[]? inspectors := null) {
		JsonTypeInspectorsImpl(inspectors ?: [
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
	
	@Operator
	abstract JsonTypeMeta getOrInspect(Type type)

	@Operator
	abstract Void set(Type type, JsonTypeMeta meta)
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
}
