
@Js
internal class TestPropertyNames : JsonTest {
	
	Void testPropNames() {
		jsonObj := inspectors.toJsonObj(T_Entity03()) as Str:Obj?
		
		verifyFalse	(jsonObj.containsKey("name"))
		verifyEq	(jsonObj["spdx"], "Booya!")
	}
}

@Js
internal class T_Entity03 {
	@JsonProperty { propertyName="spdx" }
	Str name	:= "Booya!"
}