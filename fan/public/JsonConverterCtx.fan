
mixin JsonConverterCtx {

	abstract JsonTypeMeta[]	metaStack()
	
	** A stack of Fantom objects that represent the contextual parents of converted objects.
	** 
	** Only available when converting *from* Fantom.  
	abstract Obj?[]?		fantomStack()
	
	** A stack of JSON objects that represent the contextual parents of converted objects.
	** 
	** Only available when converting *from* JSON.  
	abstract Obj?[]?		jsonStack()
	
	abstract JsonTypeMeta	inspect(Type type)

	** Returns the current 'JsonTypeMeta' being converted.
	** Convenience for:
	** 
	**   syntax: fantom
	**   metaStack.last()
	** 
	JsonTypeMeta meta() {
		metaStack.last
	}
	
	
	** For use by converters to convert embedded objects. 
	** The given arguments are pushed on to their corresponding stacks so the conversion that follows may be performed in the proper context.
	Obj? toJson(JsonTypeMeta meta, Obj? fantomObj) {
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
	Obj? toFantom(JsonTypeMeta meta, Obj? jsonObj) {
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
			 JsonInspectors	inspectors
	override JsonTypeMeta[]	metaStack
	override Obj?[]?		fantomStack
	override Obj?[]?		jsonStack
	
	new make(|This| f) { f(this) }
	
	override JsonTypeMeta inspect(Type type) {
		inspectors.getOrInspect(type)
	}
}
