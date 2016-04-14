using afConcurrent::AtomicMap

** (Service) - 
** Holds a list of 'JsonTypeInspector' instances and the cached 'JsonTypeMeta' objects.
@Js
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
			NamedInspector(Obj#,	LiteralConverter()),	// use Obj as a catch all
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
}

@Js
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
