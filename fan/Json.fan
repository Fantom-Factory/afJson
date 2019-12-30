
** A simple, easy to use JSON class.
@Js const class Json {
	
	** The JSON converters.
	const JsonConverters converters
	
	** Creates a JSON instance.
	new make([Type:JsonConverter]? converters := null, [Str:Obj?]? options := null) {
		this.converters = JsonConverters(converters, options)
	}
	
	private new withConverters(JsonConverters converters) {
		this.converters = converters
	}
	
	** Converts the given Fantom object to its JSON string representation.
	** 
	** 'options' is passed to 'JsonWriter', so may just be 'true' for pretty printing. 
	Str toJson(Obj? fantomObj, Obj? options := null) {
		converters.toJson(fantomObj, options)
	}
	
	** Converts a JSON string to the given Fantom type.
	** If 'fantomType' is 'null', then 'null' is always returned. 
	Obj? fromJson(Str? json, Type? fantomType) {
		converters.fromJson(json, fantomType)
	}
	
	** Pretty prints the given JSON string or object.
	Str prettyPrint(Obj? fantomObj, Obj? options := null) {
		if (fantomObj is Str)
			fantomObj = JsonReader().readJson(fantomObj)
		
		opts := Str:Obj?[:] { it.ordered = true }
		if (options is Bool)
			opts["prettyPrint"] = options
		else if (options is Map)
			opts.setAll(options)
		else if (options != null)
			throw ArgErr("Options must be a Bool or a Map: $options")
		
		str := JsonWriter(opts).writeJson(fantomObj)
		return str
	}

	** Converts this Json object to one with the given 'serializableMode'.
	** 
	** *Serializable Mode* is where all non-transient fields are converted, regardless of any '@JsonProperty' facets. 
	** Data from '@JsonProperty' facets, however, is still honoured if defined.
	**  
	**   syntac: fantom
	**   json := Json().withSerializableMode
	This withSerializableMode(Bool on := true) {
		Json(converters.withOptions(["afJson.serializableMode":on]))
	}
}
