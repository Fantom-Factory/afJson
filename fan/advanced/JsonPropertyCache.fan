using afConcurrent::AtomicMap

@Js @NoDoc
const class JsonPropertyCache {
	private const AtomicMap cache := AtomicMap()

	virtual JsonPropertyData[] getOrFindTags(Type type) {
		// try get() first to avoid creating the func - method.func binding doesn't work in JS
		cache.get(type) ?: cache.getOrAdd(type) { findProperties(type).toImmutable }
	}

	virtual JsonPropertyData[] findProperties(Type entityType) {
		props := (JsonPropertyData[]) entityType.fields.findAll { it.hasFacet(JsonProperty#) }.map { makeJsonPropertyData(it) }
		names := props.map { it.name }.unique

		if (props.size != names.size) {
			fields := Str:Field[:]
			props.each {
				if (fields.containsKey(it.name))
					throw Err(msgDuplicatePropertyName(it.name, fields[it.name], it.field))
				fields.add(it.name, it.field)
			}
		}
		return props
	}
	
	** Clears the tag cache. 
	virtual Void clear() {
		cache.clear
	}
	
	** Override hook for creating your own JsonPropertyData. 
	virtual JsonPropertyData makeJsonPropertyData(Field field) {
		JsonPropertyData(field)
	}
	
	private static Str msgDuplicatePropertyName(Str name, Field field1, Field field2) {
		stripSys("Property name '${name}' is defined twice at '$field1.qname' and '${field2.qname}'")
	}
	
	private static Str stripSys(Str str) {
		str.replace("sys::", "")
	}
}
