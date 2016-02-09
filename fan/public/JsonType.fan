
** An enum of JSON types.
** 
** @see `http://www.json.org/`
enum class JsonType {

	** A JSON array.
	array	(List#),
	
	** A JSON boolean.
	boolean	(Bool#),

	** A JSON null.
	nul		(null),
	
	** A JSON number.
	number	(Num#),
	
	** A JSON object.
	object	(Map#),
	
	** A JSON string.
	string	(Str#);
	
	** The Fantom 'Type' (if any) this JSON type maps to.
	const Type? type

	private new make(Type? type) {
		this.type = type
	}

	** Determines a JSON type for the given Fantom type.
	** Throws 'ArgErr' if unknown.
	static new fromType(Type? fantomType, Bool checked := true) {
		type := fantomType?.toNonNullable
			
		switch (type?.name) {
			case null:			return nul
			case "Bool":		return boolean
			case "Decimal":		return number
			case "Float":		return number
			case "Int":			return number
			case "List":		return array
			case "Map":			return object
			case "Str":			return string
			case "Num":			return number
		}

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
		return jsonType != null && jsonType != JsonType.array && jsonType != JsonType.object
	}
}
