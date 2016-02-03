
internal class TestPropertyNames : JsonTest {
	
	Void testPropNames() {
		jsonObj := json.toJson(T_Entity03()) as Str:Obj?
		
		verifyFalse	(jsonObj.containsKey("name"))
		verifyEq	(jsonObj["spdx"], "Booya!")
	}
}

internal class T_Entity03 {
	@JsonProperty { propertyName="spdx" }
	Str name	:= "Booya!"
}