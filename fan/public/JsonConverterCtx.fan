
mixin JsonConverterCtx {

	abstract JsonConverterMeta[]	metaStack()
	
	** A stack of Fantom objects that represent the contextual parents of converted objects.
	** 
	** Only available when converting *from* Fantom.  
	abstract Obj?[]?				fantomStack()
	
	** A stack of JSON objects that represent the contextual parents of converted objects.
	** 
	** Only available when converting *from* JSON.  
	abstract Obj?[]?				jsonStack()
	
	abstract JsonConverterMeta inspect(Type type)

	** Returns the current 'JsonConverterMeta' being converted.
	** Convenience for:
	** 
	**   syntax: fantom
	**   metaStack.last()
	** 
	JsonConverterMeta meta() {
		metaStack.last
	}
	
	
	** For use by converters to convert embedded objects. 
	** The given arguments are pushed on to their corresponding stacks so the conversion that follows may be performed in the proper context.
	Obj? toJson(JsonConverterMeta meta, Obj? fantomObj) {
		metaStack.push(meta)
		fantomStack.push(fantomObj)
		try {
			return meta.converter.toJson(this, fantomObj)
		} finally {
			fantomStack.pop
			metaStack.pop
		}
	}
	
	** For use by converters to convert embedded objects. 
	** The given arguments are pushed on to their corresponding stacks so the conversion that follows may be performed in the proper context.
	Obj? toFantom(JsonConverterMeta meta, Obj? jsonObj) {
		metaStack.push(meta)
		jsonStack.push(jsonObj)
		try {
			return meta.converter.toFantom(this, jsonObj)
		} finally {
			jsonStack.pop
			metaStack.pop
		}		
	}
}

internal class JsonConverterCtxImpl : JsonConverterCtx {
			 JsonInspectors			inspectors
	override JsonConverterMeta[]	metaStack
	override Obj?[]?				fantomStack
	override Obj?[]?				jsonStack
	
	new make(|This| f) { f(this) }
	
	override JsonConverterMeta inspect(Type type) {
		inspectors.getOrInspect(type)
	}
}
