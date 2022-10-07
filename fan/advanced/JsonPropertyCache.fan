using afConcurrent::AtomicMap

@Js @NoDoc
const class JsonPropertyCache {
	private const AtomicMap cache := AtomicMap()
	private const Bool pickleMode

	new make(Bool pickleMode := false) {
		this.pickleMode = pickleMode
	}

	** 'ctx' isn't used, but gives subclasses more context to adjust dynamically.
	virtual JsonPropertyData[] getOrFindTags(Type type, JsonConverterCtx ctx) {
		// try get() first to avoid creating the func - method.func binding doesn't work in JS
		cache.get(type) ?: cache.getOrAdd(type) { findProperties(type).toImmutable }
	}

	** An internal method that does the *actual* property finding.
	virtual JsonPropertyData[] findProperties(Type entityType) {
		// I dunno wot synthetic fields are but I'm guessing I dun-wan-dem!
		frops := entityType.fields.exclude { it.isStatic || it.isSynthetic }
		if (pickleMode == false)
			frops = frops.findAll { it.hasFacet(JsonProperty#) }
		else
			frops = frops.exclude { it.hasFacet(Transient#) }
		props := (JsonPropertyData[]) frops.map { makeJsonPropertyData(it) }
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
