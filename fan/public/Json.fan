
** (Service) - 
** A one-stop shop for all your JSON mapping needs!
** 
** The methods in this service may be summarised as follows:
** 
** ![JSON Methods]`jsonMethods.png`
** 
@Js
const mixin Json {
	
	** Creates a new 'Json' instance with the given inspectors.
	static new make(JsonTypeInspectors? inspectors := null, JsonReader? reader := null, JsonWriter? writer := null) {
		JsonImpl(inspectors ?: JsonTypeInspectors(), reader ?: JsonReader(), writer ?: JsonWriter())
	}
	
	** Returns the underlying 'EntityConverter' instance. 
	abstract EntityConverter converter()

	** Returns the underlying 'JsonTypeInspectors' instance. 
	abstract JsonTypeInspectors	inspectors()

	** Reads the the given JSON and (optionally) converts it to a Fantom entity instance.
	** 
	** The given JSON is read into a 'jsonObj'.
	** Should 'entityType' not be null then the 'jsonObj' is converted to a Fantom entity.
	abstract Obj? readJson(Str? json, Type? entityType := null)

	** Translates the given JSON to its Fantom List representation.
	** 
	** Convenience for '(Obj?[]?) readJson(json, null)'
	abstract Obj?[]? readJsonAsList(Str? json)
	
	** Translates the given JSON to its Fantom Map representation.
	** 
	** Convenience for '([Str:Obj?]?) readJson(json, null)'
	abstract [Str:Obj?]? readJsonAsMap(Str? json)
	
	** Converts the given obj to JSON.
	**  
	** If 'entityType' is not null then the given 'obj' is taken to be an entity and is first 
	** converted to an 'jsonObj'. The 'jsonObj' is then written out to JSON.
	** 
	** 'prettyPrintOptions' may be either a 'PrettyPrintOptions' instance, or just 'true' to enable 
	** pretty printing with defaults.
	abstract Str writeJson(Obj? obj, Type? entityType := null, Obj? prettyPrintOptions := null)

	** Converts the given entity instance to its 'jsonObj' representation.
	** 
	** If 'entityType' is 'null' it defaults to 'entity.typeof()'.
	abstract Obj? fromEntity(Obj? entity, Type? entityType := null)
	
	** Converts the given 'jsonObj' to a Fantom entity instance.
	abstract Obj? toEntity(Obj? jsonObj, Type entityType)
}

@Js
internal const class JsonImpl : Json {	
	override const EntityConverter		converter
	override const JsonTypeInspectors	inspectors
	private  const JsonReader			jsonReader
	private  const JsonWriter			jsonWriter
	
	new make(JsonTypeInspectors inspectors, JsonReader jsonReader, JsonWriter jsonWriter) {
		this.converter	= EntityConverter(inspectors)
		this.inspectors = inspectors
		this.jsonReader	= jsonReader
		this.jsonWriter	= jsonWriter
	}
	
	override Obj? readJson(Str? json, Type? entityType := null) {
		jsonObj	:= jsonReader.readJson(json)
		fantObj := entityType == null ? jsonObj : converter.toEntity(jsonObj, entityType)
		return fantObj
	}

	override Obj?[]? readJsonAsList(Str? json) {
		jsonReader.readJsonAsList(json)
	}
	
	override [Str:Obj?]? readJsonAsMap(Str? json) {
		jsonReader.readJsonAsMap(json)
	}
	
	override Str writeJson(Obj? obj, Type? entityType := null, Obj? prettyPrintOptions := null) {
		// I could forego the entity check and first convert ALL objs, 
		// but it's a bucket load faster not to when just serialising out a given jsonObj
		jsonObj	:= entityType == null ? obj : converter.fromEntity(obj, entityType)
		json 	:= jsonWriter.writeJson(jsonObj, prettyPrintOptions)
		return json
	}
	
	override Obj? fromEntity(Obj? entity, Type? entityType := null) {
		converter.fromEntity(entity, entityType)
	}
	
	override Obj? toEntity(Obj? jsonObj, Type entityType) {
		converter.toEntity(jsonObj, entityType)
	}
}
