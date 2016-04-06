
** (Service) - 
** Converts Fantom entity instances to and from their JsonObj representations.
** A JsonObj is a nested map of JSON literals.
@Js
const mixin EntityConverter {
	
	** Returns the underlying 'JsonTypeInspectors'. 
	abstract JsonTypeInspectors	inspectors()

	** Creates a new 'Json' instance with the given inspectors.
	static new make(JsonTypeInspectors? inspectors := null) {
		EntityConverterImpl(inspectors ?: JsonTypeInspectors())
	}
	
	** Converts the given entity instance to its 'jsonObj' representation.
	** 
	** If 'entityType' is null it defaults to 'entity.typeof()'.
	** 
	** If 'meta' is null then a cached version for 'entityType' is retrieved from 'JsonTypeInspectors'.
	abstract Obj? fromEntity(Obj? entity, Type? entityType := null, JsonTypeMeta? meta := null)
	
	** Converts the given 'jsonObj' to a Fantom entity instance.
	** 	
	** If 'meta' is 'null' then a cached version for 'entityType' is retrieved from 'JsonTypeInspectors'.
	abstract Obj? toEntity(Obj? jsonObj, Type entityType, JsonTypeMeta? meta := null)
}


@Js
internal const class EntityConverterImpl : EntityConverter {

	override const JsonTypeInspectors	inspectors
	
	new make(JsonTypeInspectors inspectors) {
		this.inspectors = inspectors
	}

	override Obj? fromEntity(Obj? entity, Type? entityType := null, JsonTypeMeta? meta := null) {
		meta = meta ?: inspectors.getOrInspect(entityType ?: entity.typeof)
		ctx  := JsonConverterCtxImpl {
			it.inspectors	= this.inspectors
			it.metaStack	= JsonTypeMeta[meta]
			it.fantomStack	= Obj?[,]
		}
		return meta.converter.toJsonObj(ctx, entity)
	}
	
	override Obj? toEntity(Obj? jsonObj, Type entityType, JsonTypeMeta? meta := null) {
		meta = meta ?: inspectors.getOrInspect(entityType)
		ctx  := JsonConverterCtxImpl {
			it.inspectors	= this.inspectors
			it.metaStack	= JsonTypeMeta[meta]
			it.jsonStack	= Obj?[,]
		}
		return meta.converter.toFantom(ctx, jsonObj)
	}
}
