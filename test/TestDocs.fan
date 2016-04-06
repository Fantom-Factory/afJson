
@Js
internal class TestDocs : JsonTest {
	
	Void testDocs() {
		
		user1 := Json().readJson("{}", T_User01#) as T_User01
		verifyEq(null, user1.name)
		
		json1 := Json().writeJson(user1, T_User01#)
		verifyEq(json1, "{}")

		user2 := T_User02 { name = null }
		json2 := Json().writeJson(user2, T_User02#)
		verifyEq(json2, "{\"name\":null}")

		user3 := T_User03 { name = "Dredd" }
		json3 := Json().writeJson(user3, T_User03#)
		verifyEq(json3, """{"judge":"Dredd"}""")
	}
}

@Js
internal class T_User01 {
	@JsonProperty Str? name
	new make(|This| f) { f(this) }
}

@Js
internal class T_User02 {
	@JsonProperty { storeNullValues=true } 
	Str? name
	new make(|This| f) { f(this) }
}

@Js
internal class T_User03 {
	@JsonProperty { propertyName="judge" } 
	Str? name
	new make(|This| f) { f(this) }
}
