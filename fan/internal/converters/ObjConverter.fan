using afBeanUtils::BeanFactory

** The main converter for JSON objects.
@Js @NoDoc
const class ObjConverter : JsonConverter {
	
	const Bool	storeNullValues
	const Bool	allowSurplusJson	:= true

	private const Str	removeMe	:= "afJson.removeMe"
	
	** Creates a new 'ObjConverter' with the given 'null' strategy.
	** 
	** If 'storeNullFields' is 'true' then converted 'null' values are returned in the resultant JSON.
	** If 'false' (the default) then the key / value pair is omitted.
	new make(Bool storeNullValues := false, |This|? in := null) {
		this.storeNullValues = storeNullValues
		in?.call(this) 
	}
	
	@NoDoc
	override Obj? toJsonObj(JsonConverterCtx ctx, Obj? fantomObj) {
		if (fantomObj == null) return null

		jsonMap := createJsonObj
		ctx.meta.properties.each |meta, slot| {
			fval := getValue(fantomObj, slot)
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

	@NoDoc
	override Obj? toFantom(JsonConverterCtx ctx, Obj? jsonObj) {
		if (jsonObj == null) return null

		// because ObjConverter is a catch-all converter, we sometimes get sent here by mistake
		if (jsonObj.typeof.name != "Map")
			throw Err(ErrMsgs.objConv_noConverter(ctx.meta.type, jsonObj))

		jsonMap		:= ((Str:Obj?) jsonObj).dup.rw
		jsonDup		:= jsonMap.dup.rw
		fieldVals	:= ctx.meta.properties.map |meta, slot -> Obj?| {
			// we can only set Fields!
			if (slot is Method)
				return removeMe
			
			// don't set fields that aren't in the given JSON - that allows us to set default values
			if (!jsonDup.containsKey(meta.propertyName))
				return removeMe

			field	:= (Field) slot
			jval	:= jsonDup.remove(meta.propertyName)
			fval	:= ctx.toFantom(meta, jval)
			
			if (fval == null && !field.type.isNullable) {
				// a value *is* required so decide which Err msg to throw 
				if (jsonMap.containsKey(meta.propertyName))
					throw Err(ErrMsgs.objConv_propertyIsNull(meta.propertyName, field, logDoc(jsonMap)))
				else 
					throw Err(ErrMsgs.objConv_propertyNotFound(field, meta.propertyName, logDoc(jsonMap)))
			}

//			// too much processing overhead for little value
//			// sanity check we're about to set the correct instance 
//			if (fval != null && !ReflectUtils.fits(fval.typeof, field.type))
//				throw Err(ErrMsgs.objConv_propertyDoesNotFitField(meta.propertyName, fval.typeof, field, logDoc(jsonMap)))
			
			return fval
		}.exclude { it === removeMe }
		
		if (jsonDup.size > 0)
			surplusJson(ctx, jsonDup)
		
		try return createEntity(ctx.meta.implType ?: ctx.meta.type, fieldVals)
		catch (Err err)
			throw Err("Could not create instance of ${ctx.meta.type} with: ${jsonMap}", err)
	}
	
	** Hook to return a slot value when converting to a jsonObj.
	virtual Obj? getValue(Obj fantomObj, Slot slot) {
		if (slot is Field)
			return ((Field) slot).get(fantomObj)
		if (slot is Method) {
			method := (Method) slot
			return method.isStatic ? method.call : method.call(fantomObj)
		}
		return null
	}
	
	** Hook for dealing with surplus JSON.
	virtual Void surplusJson(JsonConverterCtx ctx, Str:Obj? jsonMap) {
		if ((ctx.meta.allowSurplusJson ?: allowSurplusJson).not)
			throw Err("The following JSON keys were not mapped to ${ctx.meta.implType ?: ctx.meta.type} - $jsonMap.keys")		
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
