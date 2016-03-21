
@Js
internal class TestObjConversion : JsonTest {
	
	Void testConversion() {
		ent := json.readEntity("""{ "obj1":68, "obj2":"judge", "obj3":68.9 }""", T_Entity04#) as T_Entity04
		verifyEq(ent.obj1, 68)
		verifyEq(ent.obj2, "judge")
		verifyEq(ent.obj3, 68.9f)
	}
}

@Js
internal class T_Entity04 {
	@JsonProperty	Obj? obj1
	@JsonProperty	Obj? obj2
	@JsonProperty	Obj? obj3
}
