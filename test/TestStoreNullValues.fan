
@Js
internal class TestStoreNullValues : JsonTest {
	
	Void testNullValues() {
		jsonObj := inspectors.toJson(T_Entity02()) as Str:Obj?
		
		verify		(jsonObj.containsKey("nullTrue"))
		verifyNull	(jsonObj["nullTrue"])
		verifyFalse	(jsonObj.containsKey("nullFalse"))
		verifyFalse	(jsonObj.containsKey("nullDefault"))
	}
}

@Js
internal class T_Entity02 {
	
	@JsonProperty { storeNullValues=true }
	Str? nullTrue

	@JsonProperty { storeNullValues=false }
	Str? nullFalse

	@JsonProperty
	Str? nullDefault
}