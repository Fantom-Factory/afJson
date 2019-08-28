
@Js
internal class TestNull : Test {
	
	Void testDocs() {
		user1 := Json().fromJson("{}", T_User01#) as T_User01
		verifyEq(null, user1.name)
		
		// todo: at some point we may want to add some kind of "allowNull" property but need to investigate the effects of "undefined"
		user1 = Json().fromJson("{\"name\":null}", T_User01#) as T_User01
		verifyEq(null, user1.name)
		
		json1 := Json().toJson(user1)
		verifyEq(json1, "{\"name\":null}")
	}
}

@Js
internal class T_User01 {
	@JsonProperty Str? name
	new make(|This|? f) { f(this) }
}
