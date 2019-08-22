
@Js
internal class TestObjConversion : Test {
	
	Void testConversion() {
		ent := JsonConverters().fromJson("""{ "obj1":68, "obj2":"judge", "obj3":68.9 }""", T_Entity04#) as T_Entity04
		verifyEq(ent.obj1, 68)
		verifyEq(ent.obj2, "judge")
		verifyEq(ent.obj3, 68.9f)
	}

	Void testNoConversion() {
		verifyErrMsg(Err#, "JSON property obj2 of type Str does not fit field afJson::T_Entity02.obj2 of type Buf? : [obj1:68, obj2:judge]") {
			JsonConverters().fromJson("""{ "obj1":68, "obj2":"judge" }""", T_Entity02#)
		}
	}
}

@Js
internal class T_Entity04 {
	@JsonProperty	Obj? obj1
	@JsonProperty	Obj? obj2
	@JsonProperty	Obj? obj3

	// T_Entity04 also tests that entities can be created *without* an it-block ctor - which requires afBeanUtils::BeanFactory
}

@Js
internal class T_Entity02 {
	@JsonProperty	Obj? obj1
	@JsonProperty	Buf? obj2
}
