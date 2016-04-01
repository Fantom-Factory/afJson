
@Js
internal class TestJsonMethods : JsonTest {
	
	Void testJsonMethods() {
		json := this.json.writeEntity(T_Entity05())
		echo(json)
		verifyEq("""{"int":69,"dis":"Judge Dredd"}""", json)
		
		// and lets check we don't try to set method values!
		this.json.readEntity(json, T_Entity05#)
	}
}

@Js
internal class T_Entity05 {
	@JsonProperty
	Int	int	:= 69
	
	@JsonProperty
	Str dis() { "Judge Dredd" }
}
