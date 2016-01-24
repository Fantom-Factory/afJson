
internal class TestStoreNullValues : JsonTest {
	
	Void testNullValues() {
		jsonObj := json.toJson(T_Entity02()) as Str:Obj?
		
		verify		(jsonObj.containsKey("nullTrue"))
		verifyNull	(jsonObj["nullTrue"])
		verifyFalse	(jsonObj.containsKey("nullFalse"))
		verifyFalse	(jsonObj.containsKey("nullDefault"))
	}
}

internal class T_Entity02 {
	
	@JsonProperty { storeNullValues=true }
	Str? nullTrue

	@JsonProperty { storeNullValues=false }
	Str? nullFalse

	@JsonProperty
	Str? nullDefault
}