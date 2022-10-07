using afBeanUtils::BeanBuilder

** (Service) - 
** Converts Fantom objects to and from their JSON representation.
@Js const mixin JsonConverters {

	** Returns a new 'JsonConverters' instance.
	** 
	** If 'converters' is 'null' then 'defConvs' is used. Some defaults are:
	** 
	**   afJson.makeEntityFn      : |Type type, Field:Obj? fieldVals->Obj?| { BeanBuilder.build(type, vals) }
	**   afJson.makeJsonObjFn     : |-> Str:Obj?| { Str:Obj?[:] { ordered = true } }
	**   afJson.fromJsonHookFn    : |Obj? obj, JsonConverterCtx->Obj?| { obj }
	**   afJson.toJsonHookFn      : |Obj? obj, JsonConverterCtx->Obj?| { obj } 
	**   afJson.dateFormat        : "YYYY-MM-DD"
	**   afJson.dateTimeFormat    : "YYYY-MM-DD'T'hh:mm:ss.FFFz"
	**   afJson.strictMode        : false
	**   afJson.propertyCache     : JsonPropertyCache()
	**   afJson.pickleMode        : false
	** 
	** Override 'makeEntityFn' to have IoC create entity instances.
	** 
	** Hook fns are called *before* conversion takes place.
	** 
	** Date formats are used to serialise Date and Time objects.
	** 
	** Set 'strictMode' to 'true' to Err if the JSON contains unmapped data.
	** 
	** *Pickle Mode* is where all non '@Transient' fields are converted, regardless of any '@JsonProperty' facets. 
	** Data from '@JsonProperty' facets, however, is still honoured if defined.
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
	** 
	** 'fantomObj' is nullable so converters can create empty / default objects.
	** 'fantomType' in case 'fantomObj' is null, but defaults to 'fantomObj?.typeof'. 
	abstract Obj? toJsonVal(Obj? fantomObj, Type? fantomType := null)
	
	** Converts a JSON value to the given Fantom type.
	** 
	** If 'fantomType' is 'null' then the obj is inspected for a '_type' property,
	** else a reasonable *guess* is made (and the option 'docToTypeFn' is then called as a last resort.)
	** 
	** 'jsonVal' is nullable so converters can choose whether or not to create empty lists and maps.
	abstract Obj? fromJsonVal(Obj? jsonVal, Type? fantomType := null)	
	

	
	** Deeply converts the given Fantom List to its JSON representation.
	** 
	** Convenience for calling 'toJsonVal()' with a cast.
	abstract Obj?[]? toJsonArray(Obj?[]? fantomList)
	
	** Converts a list of JSON values to the given Fantom (non-list) type.
	** 
	**   syntax: fantom
	**   fromJsonList(list, MyEntity#)
	** 
	** Convenience for calling 'fromJsonVal()' with a cast.
	abstract Obj?[]? fromJsonArray(Obj?[]? jsonArray, Type? fantomValType := null)



	** Converts the given Fantom object to its JSON object representation.
	** 
	** Convenience for calling 'toJsonVal()' with a cast.
	abstract [Str:Obj?]? toJsonObj(Obj? fantomObj)
	
	** Converts a JSON object to the given Fantom type.
	** 
	** Convenience for calling 'fromJsonVal()' with a cast.
	** 
	** If 'fantomType' is 'null' then the obj is inspected for a '_type' property.
	abstract Obj? fromJsonObj([Str:Obj?]? jsonObj, Type? fantomType := null)
	
	

	** Converts the given Fantom object to its JSON string representation.
	** 
	** 'options' is passed to 'JsonWriter', so may just be 'true' for pretty printing. 
	abstract Str toJson(Obj? fantomObj, Obj? options := null)
	
	** Converts a JSON string to the given Fantom type.
	** If 'fantomType' is 'null', then 'null' is always returned. 
	abstract Obj? fromJson(Str? json, Type? fantomType)



	** Returns a fn that normalises '.NET' and 'snake_case' key names into standard Fantom camelCase names. 
	** 
	**   .NET examples
	**   -------------
	**   UniqueID        -->  uniqueId
	**   SWVersion       -->  swVersion
	**   MegaVERIndex    -->  megaVerIndex
	**   UtilITEMS.Rec   -->  utilItems.rec
	** 
	**   Snake_case examples
	**   -------------------
	**   unique_id       -->  uniqueId
	**   sw_Version      -->  swVersion
	**   mega_VER_Index  -->  megaVerIndex
	** 
	** Use as a hook option:
	** 
	** pre>
	** syntax: fatom
	** converters := JsonConverters(null, [
	**     "afJson.fromJsonHook" : JsonConverters.normaliseKeyNamesFn
	** ])
	** <pre
	static |Obj?->Obj?| normaliseKeyNamesFn() {	
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
	
	@NoDoc @Deprecated { msg="Use 'normaliseKeyNamesFn' instead" }
	static |Obj?->Obj?| normaliseDotNetKeyNames() { normaliseKeyNamesFn }
	
	** This seems like a handy little Str method, so we'll keep it hanging around!
	@NoDoc
	static Str _noramliseKeyName(Str str) {
		if (str.containsChar('_') || str.any |ch, i| { ch.isUpper && str.getSafe(i+1).isUpper })
			return str.containsChar('.')
				? str.split('.').map { __noramliseKeyName(it) }.join(".")
				: __noramliseKeyName(str)
		return str.decapitalize
	}

	private static Str __noramliseKeyName(Str str) {
		buf 	:= StrBuf()
		newWord := false
		str.each |ch, i| {
			if (ch == '_') {
				newWord = buf.size > 0
				return
			}

					if (i == 0)
					buf.addChar(ch.lower)
			else	if (newWord)
					{ buf.addChar(ch.upper); newWord = false }
			else	if (i+1 != str.size)
					buf.addChar(ch.isUpper && str[i-1].isUpper && (str[i+1].isUpper || str[i+1] == '_')	? ch.lower : ch)
			else	buf.addChar(ch.isUpper && str[i-1].isUpper											? ch.lower : ch)
			
		}
		return buf.toStr 
	}
}

@Js internal const class JsonConvertersImpl : JsonConverters {
	const JsonTypeLookup	typeLookup
	const JsonPropertyCache	propertyCache
	const Unsafe			optionsRef	// use Unsafe because JS can't handle immutable functions

	private new make(|This| f) { f(this) }
	
	new makeArgs(Type:JsonConverter converters, [Str:Obj?]? options) {
		
		if (options != null) {
			options = options.rw
				// rename legacy keys from < v2.0.14
				val := null
				val = 			options.remove("afJson.makeEntity")
			if (val != null)	options.set   ("afJson.makeEntityFn",	val)
				val = 			options.remove("afJson.makeJsonObj")
			if (val != null)	options.set   ("afJson.makeJsonObjFn",	val)
				val = 			options.remove("afJson.makeMap")
			if (val != null)	options.set   ("afJson.makeMapFn",		val)
				val = 			options.remove("afJson.fromJsonHook")
			if (val != null)	options.set   ("afJson.fromJsonHookFn", val)
				val = 			options.remove("afJson.toJsonHook")
			if (val != null)	options.set   ("afJson.toJsonHookFn",	val)
		}
		
		pickleMode := options?.get("afJson.pickleMode", false) == true
		this.typeLookup = JsonTypeLookup(converters)
		this.optionsRef	= Unsafe(Str:Obj?[
			"afJson.makeEntityFn"	: |Type type, Field:Obj? vals->Obj?| { BeanBuilder.build(type, vals) },
			"afJson.makeJsonObjFn"	: |-> Str:Obj?| { Str:Obj?[:] { ordered = true } },
			"afJson.makeMapFn"		: |Type t->Map| { Map((t.isGeneric ? Obj:Obj?# : t).toNonNullable) { it.ordered = true } },
			"afJson.strictMode"		: false,
			"afJson.propertyCache"	: JsonPropertyCache(pickleMode),
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
		if (newOptions.containsKey("afJson.pickleMode")) {
			pickleMode := newOptions.get("afJson.pickleMode", false) == true
			newOptions["afJson.propertyCache"] = JsonPropertyCache(pickleMode)
		}
		return JsonConvertersImpl {
			it.optionsRef		= Unsafe(this.options.rw.setAll(newOptions))
			it.propertyCache	= it.options["afJson.propertyCache"] ?: this.propertyCache
			it.typeLookup		= this.typeLookup
		}
	}
	
	override Obj? _toJsonCtx(Obj? fantomObj, JsonConverterCtx ctx) {
		hookVal := ctx.toJsonHookFn(fantomObj)		
		return get(ctx.type).toJsonVal(fantomObj, ctx)
	}

	override Obj? _fromJsonCtx(Obj? jsonVal, JsonConverterCtx ctx) {
		hookVal := ctx.fromJsonHookFn(jsonVal)
		return get(ctx.type).fromJsonVal(hookVal, ctx)
	}

	override Obj? toJsonVal(Obj? fantomObj, Type? fantomType := null) {
		if (fantomType == null) fantomType = fantomObj?.typeof
		if (fantomType == null) return null	// this null is just convenience to allow [args].map { it?.typeof }
		ctx := JsonConverterCtx.makeTop(this, fantomType, fantomObj, options)
		return _toJsonCtx(fantomObj, ctx)
	}

	override Obj? fromJsonVal(Obj? jsonVal, Type? fantomType := null) {
		if (fantomType == null) return null	// this null is just convenience to allow [args].map { it?.typeof }
		ctx := JsonConverterCtx.makeTop(this, fantomType, jsonVal, options)
		return _fromJsonCtx(jsonVal, ctx)
	}

	override Obj?[]? toJsonArray(Obj?[]? fantomList) {
		// let's not dick about - just convert null to null
		if (fantomList == null) return null
		return toJsonVal(fantomList, fantomList.typeof)
	}
	
	override Obj?[]? fromJsonArray(Obj?[]? jsonArray, Type? fantomValType := null) {
		fromJsonVal(jsonArray, fantomValType?.toListOf)
	}

	override [Str:Obj?]? toJsonObj(Obj? fantomObj) {
		// let's not dick about - just convert null to null
		if (fantomObj == null) return null
		return toJsonVal(fantomObj, fantomObj.typeof)
	}

	override Obj? fromJsonObj([Str:Obj?]? jsonObj, Type? fantomType := null) {
		fromJsonVal(jsonObj, fantomType)
	}

	override Str toJson(Obj? fantomObj, Obj? options := null) {
		// let's not dick about - just convert null to null
		if (fantomObj == null) return "null"
		jsonObj := toJsonVal(fantomObj, fantomObj.typeof)
		jsonStr := JsonWriter(options).writeJson(jsonObj)
		return jsonStr
	}
	
	override Obj? fromJson(Str? jsonStr, Type? fantomType) {
		// let's not dick about - just convert null to null
		if (jsonStr == null || fantomType == null) return null
		jsonObj := JsonReader().readJson(jsonStr)
		fantObj := fromJsonVal(jsonObj, fantomType)
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
