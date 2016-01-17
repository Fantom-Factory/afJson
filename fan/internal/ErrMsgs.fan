
internal const mixin ErrMsgs {

	static Str jsonType_unknownType(Type type) {
		"Unknown JSON type '${type.signature}'"
	}

	static Str objConv_noConverter(Type fantomType, Obj jsonObj) {
		stripSys("Could not find a Converter to ${fantomType.qname} from '${jsonObj.typeof.qname} - ${jsonObj}'")
	}

	static Str objConv_propertyNotFound(Field field, Str:Obj? jsonMap) {
		stripSys("JSON object does not contain a property for field ${field.qname} : ${jsonMap}")
	}

	static Str objConv_propertyIsNull(Str propName, Field field, Str:Obj? jsonMap) {
		stripSys("JSON object property '${propName}' is null but field ${field.qname} is NOT nullable : ${jsonMap}")
	}

//	static Str objConv_propertyDoesNotFitField(Str propName, Type propType, Field field, Str:Obj? document) {
//		stripSys("JSON object property '${propName}' of type '${propType.signature}' does not fit field ${field.qname} of type '${field.type.signature}' : ${document}")
//	}
	
	static Str stripSys(Str str) {
		str.replace("sys::", "")
	}
}
