
** Passed to 'JsonConverters' to give context on what they're converting.
@Js class JsonConverterCtx {
	JsonConverterCtx?	parent		{ private set }
		  Type			type		{ private set }
	
	const Bool			isField
	const Field?		field
	const JsonProperty?	jsonProperty
		  Obj?			obj			{ private set }
	
	const Bool			isMap
	const Obj?			mapKey
		  Map?			map			{ private set }
	
	const Bool			isList
	const Int?			listIdx
		  List?			list		{ private set }

		  Str:Obj?		options
	
		 JsonConverters converters	{ private set }

	private new make(|This| f) { f(this) }

	internal new makeTop(JsonConverters converters, Type type, Obj? obj, Str:Obj? options) {
		this.converters = converters
		this.type		= type
		this.obj		= obj
		this.options	= options
	}

	This makeField(Type type, Field field, JsonProperty? jsonProperty, Obj? obj) {
		// pass type, because the impl type may be different to the defined field.type
		JsonConverterCtx {
			it.parent		= this
			it.type			= type
			it.isField		= true
			it.field		= field
			it.jsonProperty	= jsonProperty
			it.obj			= obj
			it.converters	= this.converters
			it.options		= this.options
		}
	}

	This makeMap(Type type, Map map, Obj key, Obj? obj) {
		JsonConverterCtx {
			it.parent		= this
			it.type			= type
			it.isMap		= true
			it.map			= map
			it.mapKey		= key
			it.obj			= obj
			it.converters	= this.converters
			it.options		= this.options
		}
	}

	This makeList(Type type, List list, Int idx, Obj? obj) {
		JsonConverterCtx {
			it.parent		= this
			it.type			= type
			it.isList		= true
			it.list			= list
			it.listIdx		= idx
			it.obj			= obj
			it.converters	= this.converters
			it.options		= this.options
		}
	}	

	Bool isTopLevel() {
		parent == null
	}
	
	** Uses *this* context to convert 'this.obj'.
	Obj? toJsonVal() {
		converters._toJsonCtx(obj, this)
	}

	** Uses *this* context to convert 'this.obj'.
	Obj? fromJsonVal() {
		converters._fromJsonCtx(obj, this)
	}
	
	** Replace 'type' with a more specific subclass type.
	Void replaceType(Type newType) {
		if (!newType.fits(type))
			throw Err("Replacement types must be a Subtype: $newType -> $type")
		this.type = newType
	}
	
	// ---- Option Functions ----
	
	** Creates an empty *ordered* JSON object. 
	@NoDoc Str:Obj? makeJsonObjFn() {
		((|JsonConverterCtx->Str:Obj?|) options["afJson.makeJsonObjFn"])(this)
	}

	** Creates an Entity instance. 
	@NoDoc Obj? makeEntityFn(Field:Obj? fieldVals) {
		((|Type, Field:Obj?, JsonConverterCtx->Obj?|) options["afJson.makeEntityFn"])(this.type, fieldVals, this)
	}

	** Creates an empty map for Fantom.
	@NoDoc Obj:Obj? makeMapFn() {
		((|Type,JsonConverterCtx->Obj:Obj?|) options["afJson.makeMapFn"])(this.type, this)
	}
	
	** This is called *before* any 'jsonVal' is converted. 
	@NoDoc Obj? fromJsonHookFn(Obj? jsonVal) {
		((|Obj?, JsonConverterCtx->Obj?|?) options["afJson.fromJsonHookFn"])?.call(jsonVal, this) ?: jsonVal
	}
	
	** This is called *before* any 'fantomObj' is converted. 
	@NoDoc Obj? toJsonHookFn(Obj? fantomObj) {
		((|Obj?, JsonConverterCtx->Obj?|?) options["afJson.toJsonHookFn"])?.call(fantomObj, this) ?: fantomObj
	}
	
	** Returns the 'JsonPropertyCache'.
	@NoDoc JsonPropertyCache optJsonPropertyCache() {
		options["afJson.propertyCache"]
	}
	
	** Returns strict mode.
	@NoDoc Bool optStrictMode() {
		options.get("afJson.strictMode", false)
	}
	
	** Returns the Date format, with an ISO default if unspecified.
	@NoDoc Str optDateFormat() {
		options.get("afJson.dateFormat", "YYYY-MM-DD")
	}

	** Returns the DateTime format, with an ISO default if unspecified.
	@NoDoc Str optDateTimeFormat() {
		options.get("afJson.dateTimeFormat", "YYYY-MM-DD'T'hh:mm:ss.FFFz zzzz")
	}
}
