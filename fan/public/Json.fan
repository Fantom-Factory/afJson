
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
	
	** Returns the underlying 'JsonTypeInspectors'. 
	abstract JsonTypeInspectors	inspectors()

	** Reads the the given JSON and converts it to a Fantom entity instance.
	abstract Obj? readEntity(Str? json, Type fantomType)

	** Converts the given entity to JSON.
	** 
	** If 'fantomType' is 'null' it defaults to the type of the given obj.
	abstract Str writeEntity(Obj? fantomObj, Type? fantomType := null)

	** Translates the given JSON to a Fantom 'Obj'.
	abstract Obj? readObj(Str? json)

	** Translates the given JSON to a Fantom 'Map'.
	** 
	** Convenience for '([Str:Obj?]?) readObj(...)'
	abstract [Str:Obj?]? readMap(Str? json)
	
	** Convenience for serialising the given Fantom object to JSON.
	** 
	** 'prettyPrintOptions' may be either a 'PrettyPrintOptions' instance, or just 'true' to enable 
	** pretty printing with defaults.
	abstract Str writeObj(Obj? obj, Obj? prettyPrintOptions := null)
	
	** Converts the given entity to its JSON representation.
	** 
	** If 'fantomType' is 'null' it defaults to 'fantomObj.typeof()'.
	** 
	** If 'meta' is 'null' then a cached version for 'fantomType' is retrieved from 'JsonTypeInspectors'.
	abstract Obj? toJsonObj(Obj? fantomObj, Type? fantomType := null, JsonTypeMeta? meta := null)
	
	** Converts the given 'jsonObj' to its Fantom representation.
	** 	
	** If 'meta' is 'null' then a cached version for 'fantomType' is retrieved from 'JsonTypeInspectors'.
	abstract Obj? toFantom(Obj? jsonObj, Type fantomType, JsonTypeMeta? meta := null)
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
	
	override Obj? readObj(Str? json) {
		jsonReader.readObj(json)
	}

	override [Str:Obj?]? readMap(Str? json) {
		jsonReader.readMap(json)
	}
	
	override Str writeObj(Obj? obj, Obj? prettyPrintOptions := null) {
		jsonWriter.writeObj(obj, prettyPrintOptions)
	}

	override Obj? toJsonObj(Obj? fantomObj, Type? fantomType := null, JsonTypeMeta? meta := null) {
		inspectors.toJsonObj(fantomObj, fantomType, meta)
	}
	
	override Obj? toFantom(Obj? jsonObj, Type fantomType, JsonTypeMeta? meta := null) {
		inspectors.toFantom(jsonObj, fantomType, meta)
	}
}
