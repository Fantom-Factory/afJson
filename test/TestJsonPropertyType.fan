
@Js internal class TestJsonPropertyType : Test {
	
	Void testFromJson() {
		jsonObj := [
			"inty"	: 42f
		]
		
		entity := (T_Entity10) JsonConverters().fromJsonVal(jsonObj, T_Entity10#)
		
		verifyEq(entity.inty, 	42)
	}
	
	Void testToJson() {
		entity := T_Entity10() {
			inty	= 42
		}
		
		jsonObj := JsonConverters().toJsonObj(entity)
		
		verifyEq(jsonObj["inty"],	42)
	}
}

@Js internal class T_Entity10 {
	@JsonProperty { implType=Int# }
			Num			inty

	new make(|This|in) { in(this) }
}
