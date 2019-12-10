using afBeanUtils::BeanBuilder

** (Service) - 
** Converts Fantom objects to and from their JSON representation.
@Js const mixin JsonConverters {

	** Returns a new 'JsonConverters' instance.
	** 
	** If 'converters' is 'null' then 'defConvs' is used. Common options are:
	** 
	**   afJson.makeEntity        : |Type type, Field:Obj? fieldVals->Obj?| { BeanBuilder.build(type, vals) }
	**   afJson.strictMode        : false
	**   afJson.dateFormat        : "YYYY-MM-DD"
	**   afJson.dateTimeFormat    : "YYYY-MM-DD'T'hh:mm:ss.FFFz"
	**   afJson.propertyCache     : JsonPropertyCache()
	**   afJson.serializableMode  : true
	** 
	** Override 'makeEntity' to have IoC create entity instances.
	** Set 'strictMode' to 'true' to Err if the JSON contains unmapped data.
	** 
	** 'serializableMode' attempts to serialise ALL fields, unless they're marked as '@Transient'.
	static new make([Type:JsonConverter]? converters := null, [Str:Obj?]? options := null) {
		JsonConvertersImpl(converters ?: defConvs, options)
	}

	** Returns a new 'JsonConverters' whose options are overridden with the given ones.
	abstract JsonConverters withOptions(Str:Obj? newOptions)
	
	** Returns the 'Converter' instance used to convert the given type. 
	@Operator
	abstract JsonConverter get(Type type)

	** The default set of JSON <-> Fantom converters.
	static Type:JsonConverter defConvs() {
		JsonConvertersImpl._defConvs
	}



	@NoDoc	// not sure why we'd want these to be pubic?
	internal abstract Obj? _toJsonCtx(Obj? fantomObj, JsonConverterCtx ctx)

	@NoDoc	// not sure why we'd want these to be pubic?
	internal abstract Obj? _fromJsonCtx(Obj? jsonVal, JsonConverterCtx ctx)
	
	

	** Converts the given Fantom object to its JSON representation.
	** If 'fantomType' is 'null' then 'null' is always returned. 
	** 
	** 'fantomType' is required in case 'fantomObj' is null. 
	** 'fantomObj' is nullable so converters can create empty / default objects.
	abstract Obj? toJsonVal(Obj? fantomObj, Type? fantomType)
	
	** Converts a JSON value to the given Fantom type.
	** If 'fantomType' is 'null' then 'null' is always returned. 
	** 
	** 'jsonVal' is nullable so converters can choose whether or not to create empty lists and maps.
	abstract Obj? fromJsonVal(Obj? jsonVal, Type? fantomType)



	** Converts the given Fantom object to its JSON object representation.
	** 
	** 'fantomObj' is nullable so converters can create empty / default objects.
	abstract [Str:Obj?]? toJsonObj(Obj? fantomObj)
	
	** Converts a JSON object to the given Fantom type.
	** 
	** 'jsonObj' is nullable so converters can choose whether or not to create empty lists and maps.
	abstract Obj? fromJsonObj([Str:Obj?]? jsonObj, Type fantomType)
	
	

	** Converts the given Fantom object to its JSON string representation.
	** 
	** 'options' is passed to 'JsonWriter', so may just be 'true' for pretty printing. 
	abstract Str toJson(Obj? fantomObj, Obj? options := null)
	
	** Converts a JSON string to the given Fantom type.
	abstract Obj? fromJson(Str? json, Type fantomType)



	** Returns a fn that normalises .NET JSON key names into standard Fantom camelCase names. 
	** 
	** Use as a hook option:
	** 
	** pre>
	** syntax: fatom
	** converters := JsonConverters(null, [
	**     "afJson.fromJsonHook" : JsonConverters.normaliseDotNetKeyNames
	** ])
	** <pre
	static |Obj?->Obj?| normaliseDotNetKeyNames() {	
		|Obj? obj->Obj?| {
			if (obj is Map) {
				oldMap := (Str:Obj?) obj
				newMap :=  Str:Obj?  [:]
				oldMap.each |val, key| {
					newMap[_noramliseKeyName(key)] = val
				}
				return newMap
			}
			return obj
		}
	}
	
	** This seems like a handy little Str method, so we'll keep it hanging around!
	@NoDoc
	static Str _noramliseKeyName(Str str) {
		net := str.any |ch, i| { ch.isUpper && str.getSafe(i+1).isUpper }
		if (net == false)
			return str.decapitalize

		return str.containsChar('.')
			? str.split('.').map { __noramliseKeyName(it) }.join(".")
			: __noramliseKeyName(str)
	}

	private static Str __noramliseKeyName(Str str) {
		buf := StrBuf()
		str.each |ch, i| {
					if (i == 0)
					buf.addChar(ch.lower)
			else	if (i+1 != str.size)
					buf.addChar(ch.isUpper && str[i-1].isUpper && str[i+1].isUpper	? ch.lower : ch)
			else	buf.addChar(ch.isUpper && str[i-1].isUpper						? ch.lower : ch)
		}
		return buf.toStr 
	}
}

@Js internal const class JsonConvertersImpl : JsonConverters {
	const JsonTypeLookup	typeLookup
	const JsonPropertyCache	propertyCache
	const Unsafe			optionsRef	// use Unsafe because JS can't handle immutable functions

	new make(|This| f) { f(this) }
	
	new makeArgs(Type:JsonConverter converters, [Str:Obj?]? options) {
		serializableMode := options?.get("afJson.serializableMode", false) == true
		this.typeLookup = JsonTypeLookup(converters)
		this.optionsRef	= Unsafe(Str:Obj?[
			"afJson.makeEntity"		: |Type type, Field:Obj? vals->Obj?| { BeanBuilder.build(type, vals) },
			"afJson.makeJsonObj"	: |-> Str:Obj?| { Str:Obj?[:] { ordered = true } },
			"afJson.makeMap"		: |Type t->Map| { Map((t.isGeneric ? Obj:Obj?# : t).toNonNullable) { it.ordered = true } },
			"afJson.strictMode"		: false,
			"afJson.propertyCache"	: JsonPropertyCache(serializableMode),
		])
		
		if (options != null)
			this.optionsRef = Unsafe(this.options.rw.setAll(options))

		if (Env.cur.runtime != "js")
			// JS can't handle immutable functions, but I'd still like them to be thread safe in Java
			optionsRef = Unsafe(optionsRef.val.toImmutable)
		
		this.propertyCache	= this.options["afJson.propertyCache"]
	}

	Str:Obj? options() { optionsRef.val }
	
	override JsonConverters withOptions(Str:Obj? newOptions) {
		if (newOptions.containsKey("afJson.serializableMode")) {
			serializableMode := newOptions.get("afJson.serializableMode", false) == true
			newOptions["afJson.propertyCache"] = JsonPropertyCache(serializableMode)
		}
		return JsonConvertersImpl {
			it.optionsRef		= Unsafe(this.options.rw.setAll(newOptions))
			it.propertyCache	= it.options["afJson.propertyCache"] ?: this.propertyCache
			it.typeLookup		= this.typeLookup
		}
	}
	
	override Obj? _toJsonCtx(Obj? fantomObj, JsonConverterCtx ctx) {
		hookVal := ctx.fnToJsonHook(fantomObj)		
		return get(ctx.type).toJsonVal(fantomObj, ctx)
	}

	override Obj? _fromJsonCtx(Obj? jsonVal, JsonConverterCtx ctx) {
		hookVal := ctx.fnFromJsonHook(jsonVal)
		return get(ctx.type).fromJsonVal(hookVal, ctx)
	}

	override Obj? toJsonVal(Obj? fantomObj, Type? fantomType) {
		if (fantomType == null) return null	// this null is just convenience to allow [args].map { it?.typeof }
		ctx := JsonConverterCtx.makeTop(this, fantomType, fantomObj, options)
		return _toJsonCtx(fantomObj, ctx)
	}

	override Obj? fromJsonVal(Obj? jsonVal, Type? fantomType) {
		if (fantomType == null) return null	// this null is just convenience to allow [args].map { it?.typeof }
		ctx := JsonConverterCtx.makeTop(this, fantomType, jsonVal, options)
		return _fromJsonCtx(jsonVal, ctx)
	}
	
	override [Str:Obj?]? toJsonObj(Obj? fantomObj) {
		// let's not dick about - just convert null to null
		if (fantomObj == null) return null
		return toJsonVal(fantomObj, fantomObj.typeof)
	}

	override Obj? fromJsonObj([Str:Obj?]? jsonObj, Type fantomType) {
		fromJsonVal(jsonObj, fantomType)
	}

	override Str toJson(Obj? fantomObj, Obj? options := null) {
		// let's not dick about - just convert null to null
		if (fantomObj == null) return "null"
		jsonObj := toJsonObj(fantomObj)
		jsonStr := JsonWriter(options).writeJson(jsonObj)
		return jsonStr
	}
	
	override Obj? fromJson(Str? jsonStr, Type fantomType) {
		// let's not dick about - just convert null to null
		if (jsonStr == null) return null
		jsonObj := JsonReader().readJson(jsonStr)
		fantObj := fromJsonObj(jsonObj, fantomType)
		return fantObj
	}

	override JsonConverter get(Type type) {
		// if a specific converter can't be found then embed a record
		typeLookup.findParent(type)
	}
	
	static Type:JsonConverter _defConvs() {
		config				:= Type:JsonConverter[:]
		jsonLiteral			:= JsonLiteralConverter()
		numLiteral			:= JsonNumConverter()

		// JSON Literals - https://json.org/
		config[Bool#]		= jsonLiteral
		config[Float#]		= numLiteral
		config[Decimal#]	= numLiteral
		config[Int#]		= numLiteral
		config[JsLiteral#]	= jsonLiteral
		config[Num#]		= numLiteral
		config[Str#]		= jsonLiteral
		
		// Containers
		config[Obj#]		= JsonObjConverter()
		config[Map#]		= JsonMapConverter()
		config[List#]		= JsonListConverter()

		// Fantom Literals
		config[Date#]		= JsonDateConverter()
		config[DateTime#]	= JsonDateTimeConverter()
		config[Depend#]		= JsonSimpleConverter(Depend#)
		config[Duration#]	= JsonSimpleConverter(Duration#)
		config[Enum#]		= JsonEnumConverter()
		config[Locale#]		= JsonSimpleConverter(Locale#)
		config[MimeType#]	= JsonSimpleConverter(MimeType#)
		config[Range#]		= JsonSimpleConverter(Range#)
		config[Regex#]		= JsonSimpleConverter(Regex#)
		config[Slot#]		= JsonSlotConverter()
		config[Time#]		= JsonSimpleConverter(Time#)
		config[TimeZone#]	= JsonSimpleConverter(TimeZone#)
		config[Type#]		= JsonTypeConverter()
		config[Unit#]		= JsonSimpleConverter(Unit#)
		config[Uri#]		= JsonSimpleConverter(Uri#)
		config[Uuid#]		= JsonSimpleConverter(Uuid#)
		config[Version#]	= JsonSimpleConverter(Version#)
		
		return config
	}
}
