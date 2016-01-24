using afBeanUtils::BeanFactory

** The main converter for JSON objects.
@NoDoc
const class ObjConverter : JsonConverter {
	
	** If 'false' then 
	const Bool	storeNullValues

	** Creates a new 'ObjConverter' with the given 'null' strategy.
	** 
	** If 'storeNullFields' is 'true' then converted 'null' values are returned in the resultant JSON.
	** If 'false' (the default) then the key / value pair is omitted.
	new make(Bool storeNullValues := false, |This|? in := null) {
		this.storeNullValues = storeNullValues
		in?.call(this) 
	}
	
	override Obj? toJson(JsonConverterCtx ctx, Obj? fantomObj) {
		if (fantomObj == null) return null

		jsonMap := createJsonObj
		ctx.meta.properties.each |meta, field| {
			fval := field.get(fantomObj)
			jval := ctx.toJson(meta, fval)
			
			if (jval == null && (meta.storeNullValues ?: storeNullValues).not)
				// bug out if we're not storing null values
				return

			// use add, rather than set, so an Err is thrown should we accidently try to add the 
			// same name twice (from using the Property@name facet)
			jsonMap.add(meta.propertyName, jval)
		}
		return jsonMap
	}

	override Obj? toFantom(JsonConverterCtx ctx, Obj? jsonObj) {
		if (jsonObj == null) return null

		// because ObjConverter is a catch-all converter, we sometimes get sent here by mistake
		if (jsonObj.typeof.name != "Map")
			throw Err(ErrMsgs.objConv_noConverter(ctx.meta.type, jsonObj))

		jsonMap := (Str:Obj) jsonObj
		fieldVals := ctx.meta.properties.map |meta, field -> Obj?| {
			jval := jsonMap[meta.propertyName]
			fval := ctx.toFantom(meta, jval)
			
			if (fval == null && !field.type.isNullable) {
				// a value *is* required so decide which Err msg to throw 
				if (jsonMap.containsKey(meta.propertyName))
					throw Err(ErrMsgs.objConv_propertyIsNull(meta.propertyName, field, logDoc(jsonMap)))
				else 
					throw Err(ErrMsgs.objConv_propertyNotFound(field, logDoc(jsonMap)))
			}

//			// too much processing overhead for little value
//			// sanity check we're about to set the correct instance 
//			if (fval != null && !ReflectUtils.fits(fval.typeof, field.type))
//				throw Err(ErrMsgs.objConv_propertyDoesNotFitField(meta.propertyName, fval.typeof, field, logDoc(jsonMap)))
			
			return fval
		}
		
		try return createEntity(ctx.meta.implType ?: ctx.meta.type, fieldVals)
		catch (Err err)
			throw Err("Could not create instance of ${ctx.meta.type} with: ${fieldVals}", err)
	}
	
	** Creates an Entity instance using [BeanFactory]`afBeanUtils::BeanFactory`.
	** 
	** Override if you prefer your entities to be autobuilt by IoC.
	virtual Obj? createEntity(Type type, Field:Obj? fieldVals) {
		BeanFactory(type, null, fieldVals).create
	}
	
	** Creates an empty *ordered* JSON map.
	** 
	** Override if you prefer your JSON maps unordered or case-insensitive.
	virtual Str:Obj? createJsonObj() {
		Str:Obj?[:] { it.ordered = true }
	}

	private static const Type[] literals	:= [Bool#, Date#, DateTime#, Decimal#, Duration#, Enum#, Float#, Int#, Regex#, Range#, Slot#, Str#, Type#]

	private Str:Str logDoc(Str:Obj? document) {
		document.map |val->Str| {
			if (val == null) return "null"
			if (literals.contains(val.typeof.toNonNullable))
				return val.toStr
			return "..." 
		}
	}
}
