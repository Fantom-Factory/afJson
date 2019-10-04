using afBeanUtils
using afConcurrent

** A 'TypeLookup' that caches the lookup results.
@Js internal const class JsonTypeLookup : TypeLookup {
	private const AtomicMap parentCache   := AtomicMap()
	private const AtomicMap childrenCache := AtomicMap()

	new make(Type:Obj? values) : super(values) { }
	
	** Cache the lookup results
	override Obj? findParent(Type type, Bool checked := true) {
		nonNullable := type.toNonNullable
		// TODO try get first - avoid creating the func - or bind a method in ctor
		return parentCache.getOrAdd(nonNullable) { doFindParent(nonNullable, checked) } 
	}
	
	** Cache the lookup results
	override Obj?[] findChildren(Type type, Bool checked := true) {
		nonNullable := type.toNonNullable
		// TODO try get first - avoid creating the func - or bind a method in ctor
		return childrenCache.getOrAdd(nonNullable) { doFindChildren(nonNullable, checked) } 
	}

	** Clears the lookup cache 
	Void clear() {
		parentCache.clear
		childrenCache.clear
	}
}