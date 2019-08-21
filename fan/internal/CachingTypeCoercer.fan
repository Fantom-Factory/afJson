using afBeanUtils::TypeCoercer
using afConcurrent::AtomicMap

** A 'TypeCoercer' that caches its conversion methods.
@Js internal const class CachingTypeCoercer : TypeCoercer {
	private const AtomicMap cache := AtomicMap()

	** Cache the conversion functions
	override protected |Obj->Obj|? createCoercionFunc(Type fromType, Type toType) {
		// can't store immutable funcs in JS
		if (Env.cur.runtime == "js")
			return doCreateCoercionFunc(fromType, toType)

		key	:= "${fromType.qname}->${toType.qname}"
		return cache.getOrAdd(key) { doCreateCoercionFunc(fromType, toType) } 
	}

	** Clears the function cache 
	Void clear() {
		cache.clear
	}
}
