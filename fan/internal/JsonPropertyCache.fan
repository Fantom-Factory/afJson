using afConcurrent::AtomicMap

@NoDoc
@Js internal const class JsonPropertyCache {
	private const AtomicMap cache := AtomicMap()

	virtual JsonPropertyData[] getOrFindTags(Type type) {
		if (!cache.containsKey(type))
			cache.set(type, findProperties(type).toImmutable)
		return cache.get(type)
	}

	private JsonPropertyData[] findProperties(Type entityType) {
		props := (JsonPropertyData[]) entityType.fields.findAll { it.hasFacet(JsonProperty#) }.map { JsonPropertyData(it) }
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
	
	private static Str msgDuplicatePropertyName(Str name, Field field1, Field field2) {
		stripSys("Property name '${name}' is defined twice at '$field1.qname' and '${field2.qname}'")
	}
	
	private static Str stripSys(Str str) {
		str.replace("sys::", "")
	}
}
