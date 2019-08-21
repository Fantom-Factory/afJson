
@Js class JsonConverterCtx {
	JsonConverterCtx?	parent	{ private set }
	const Type			type
	
	const Bool			isField
	const Field?		field
	const JsonProperty?	jsonProperty
		  Obj?			obj		{ private set }
	
	const Bool			isMap
	const Obj?			mapKey
		  Map?			map		{ private set }
	
	const Bool			isList
	const Int?			listIdx
		  List?			list	{ private set }

		  Str:Obj?		options
	
	private JsonConverters converters

	private new make(|This| f) { f(this) }

	internal new makeTop(JsonConverters converters, Type type, Obj? obj, Str:Obj? options) {
		this.converters = converters
		this.type		= type
		this.obj		= obj
		this.options	= options
	}

	This makeField(Type type, Field field, JsonProperty jsonProperty, Obj? obj) {
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
	
	** Uses *this* context to convert 'obj'.
	Obj? toJsonVal() {
		converters.toJsonCtx(obj, this)
	}

	** Uses *this* context to convert 'obj'.
	Obj? fromJsonVal() {
		converters.fromJsonCtx(obj, this)
	}
}
