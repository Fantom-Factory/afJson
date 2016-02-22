
@Js
internal class TestDocs : JsonTest {
	
	Void testDocs() {
		
		user1 := Json().readEntity("{}", T_User1#) as T_User1
		verifyEq(null, user1.name)
		
		json1 := Json().writeEntity(user1)
		verifyEq(json1, "{}")

		user2 := T_User2 { name = null }
		json2 := Json().writeEntity(user2)
		verifyEq(json2, "{\"name\":null}")

		user3 := T_User3 { name = "Dredd" }
		json3 := Json().writeEntity(user3)
		verifyEq(json3, """{"judge":"Dredd"}""")
	}
}

@Js
internal class T_User1 {
	@JsonProperty Str? name
	new make(|This| f) { f(this) }
}

@Js
internal class T_User2 {
	@JsonProperty { storeNullValues=true } 
	Str? name
	new make(|This| f) { f(this) }
}

@Js
internal class T_User3 {
	@JsonProperty { propertyName="judge" } 
	Str? name
	new make(|This| f) { f(this) }
}
