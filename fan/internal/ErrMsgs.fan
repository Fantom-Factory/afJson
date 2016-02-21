using afBeanUtils

@Js
internal const mixin ErrMsgs {

	static Str jsonType_unknownType(Type type) {
		"Unknown JSON type '${type.signature}'"
	}

	static Str objInspect_implTypeDoesNotFit(Type implType, Field field) {
		"implType ${implType.qname} on field ${field.qname} does not fit field type of ${field.type.qname}"
	}

	static Str objConv_noConverter(Type fantomType, Obj jsonObj) {
		stripSys("Could not find a Converter to ${fantomType.qname} from ${jsonObj.typeof.qname}: ${jsonObj}")
	}

	static Str objConv_propertyNotFound(Field field, Str:Obj? jsonMap) {
		stripSys("Could not set field '${field.qname}' because I couldn't find a matching JSON property in : ${jsonMap}")
	}

	static Str objConv_propertyIsNull(Str propName, Field field, Str:Obj? jsonMap) {
		stripSys("JSON object property '${propName}' is null but field ${field.qname} is NOT nullable : ${jsonMap}")
	}

//	static Str objConv_propertyDoesNotFitField(Str propName, Type propType, Field field, Str:Obj? document) {
//		stripSys("JSON object property '${propName}' of type '${propType.signature}' does not fit field ${field.qname} of type '${field.type.signature}' : ${document}")
//	}
	
	static Str mapConverter_cannotCoerceKey(Type keyType) {
		stripSys("Unsupported Map key type ${keyType.qname}, cannot coerce from Str#. See ${TypeCoercer#.qname} for details.")
	}

	static Str stripSys(Str str) {
		str.replace("sys::", "")
	}
}
