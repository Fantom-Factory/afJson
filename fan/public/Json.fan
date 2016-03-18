
** (Service) - 
** A one-stop shop for all your JSON mapping needs!
@Js
const mixin Json {
	
	** Creates a new 'Json' instance with the given inspectors.
	static new make(JsonTypeInspectors? inspectors := null, JsonReader? reader := null, JsonWriter? writer := null) {
		JsonImpl(inspectors ?: JsonTypeInspectors(), reader ?: JsonReader(), writer ?: JsonWriter())
	}
	
	** Returns the underlying 'JsonTypeInspectors'. 
	abstract JsonTypeInspectors	inspectors()

	** Converts the given entity to JSON.
	** 
	** If 'fantomType' is 'null' it defaults to the type of the given obj.
	abstract Str writeEntity(Obj? fantomObj, Type? fantomType := null)

	** Reads the the given JSON and converts it to a Fantom entity instance.
	abstract Obj? readEntity(Str? json, Type fantomType)
}

@Js
internal const class JsonImpl : Json {	
	override const JsonTypeInspectors	inspectors
	private  const JsonReader			jsonReader
	private  const JsonWriter			jsonWriter
	
	new make(JsonTypeInspectors inspectors, JsonReader jsonReader, JsonWriter jsonWriter) {
		this.inspectors = inspectors
		this.jsonReader	= jsonReader
		this.jsonWriter	= jsonWriter
	}
	
	override Str writeEntity(Obj? fantomObj, Type? fantomType := null) {
		jsonObj	:= inspectors.toJsonObj(fantomObj, fantomType)
		json 	:= jsonWriter.writeObj(jsonObj)
		return json
	}

	override Obj? readEntity(Str? json, Type fantomType) {
		jsonObj	:= jsonReader.readObj(json)
		entity	:= inspectors.toFantom(jsonObj, fantomType)
		return entity
	}
}
