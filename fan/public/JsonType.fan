
** A list of JSON types.
** 
** @see `http://www.json.org/`
enum class JsonType {

	ARRAY	(List#),
	BOOL	(Bool#),
	NULL	(null),
	NUMBER	(Num#),
	OBJECT	(Map#),
	STRING	(Str#);
	
	** The Fantom 'Type' (if any) this JSON type maps to.
	const Type? type

	private new make(Type? type) {
		this.type = type
	}

	** Determines a JSON type from the type of the given object.
	** Throws an 'ArgErr' if invalid.
	static new fromType(Type? fantomType, Bool checked := true) {
		type := fantomType?.toNonNullable
			
		// switch on final / native types
		switch (type) {
			case Bool#:	return BOOL
			case Num#:	return NUMBER
			case Str#:	return STRING
			case null:	return NULL
		}

		// can't switch on parameterised types
		if (fantomType.name == "List")	return ARRAY
		// a controversial decision - we check individual key types, not the map key type
		if (fantomType.name == "Map")	return OBJECT	

		return null ?: (checked ? throw ArgErr(ErrMsgs.jsonType_unknownType(type)) : null)
	}
	
	** Returns true if the given 'Type' is a JSON literal. 
	** 'null' is considered a literal, whereas 'Map' and 'List' are not.
	** 
	**   JsonType.isLiteral(Float#)    // --> true
	**   JsonType.isLiteral(null)      // --> true
	** 
	**   JsonType.isLiteral(List#)     // --> false
	**   JsonType.isLiteral(Str:Obj?#) // --> false
	static Bool isLiteral(Type? type) {
		jsonType := JsonType.fromType(type, false)
		return jsonType != null && jsonType != JsonType.ARRAY && jsonType != JsonType.OBJECT
	}
}
