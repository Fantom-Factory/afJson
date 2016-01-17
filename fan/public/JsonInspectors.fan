using afConcurrent

//@NoDoc	// Advanced use only!
** (Service) - 
const mixin JsonInspectors {

	abstract JsonConverterMeta inspect(Type type)
}

internal const class JsonInspectorsImpl : JsonInspectors {
	private const AtomicMap			metaObjs	:= AtomicMap { it.keyType=Type#; it.valType=JsonConverterMeta# }
	private const JsonInspector[] 	jsonInspectors
	
	new make(JsonInspector[] jsonInspectors) {
		this.jsonInspectors = jsonInspectors
	}

	override JsonConverterMeta inspect(Type type) {
		metaObjs.getOrAdd(type) { 
			jsonInspectors.eachWhile { it.inspect(type, this) } ?: Err("Could not find Inspector to process ${type.qname}")
		}
	}
}
