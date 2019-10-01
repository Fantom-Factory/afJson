//
//@Js
//internal class TestJsonMethods : JsonTest {
//	
//	Void testJsonMethods() {
//		json := this.json.writeJson(T_Entity05(), T_Entity05#)
//		echo(json)
//		verifyEq("""{"int":69,"dis":"Judge Dredd"}""", json)
//		
//		// and lets check we don't try to set method values!
//		this.json.readJson(json, T_Entity05#)
//	}
//}
//
//@Js
//internal class T_Entity05 {
//	@JsonProperty
//	Int	int	:= 69
//	
//	@JsonProperty
//	Str dis() { "Judge Dredd" }
//}
