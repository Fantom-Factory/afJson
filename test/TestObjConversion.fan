
@Js internal class TestObjConversion : Test {
	
	Void testConversion() {
		ent := JsonConverters().fromJson("""{ "obj1":68, "obj2":"judge", "obj3":68.9, "obj4":{"foo":"bar"} }""", T_Entity04#) as T_Entity04
		verifyEq(ent.obj1, 68)
		verifyEq(ent.obj2, "judge")
		verifyEq(ent.obj3, 68.9f)
		verifyEq(ent.obj4, Str:Obj?["foo":"bar"])
	}

	Void testNoConversion() {
		verifyErrMsg(Err#, "JSON property obj2 of type Str does not fit field afJson::T_Entity02.obj2 of type Buf? : [obj1:68, obj2:judge]") {
			JsonConverters().fromJson("""{ "obj1":68, "obj2":"judge" }""", T_Entity02#)
		}
	}
	
	Void testKnownTypeConverstion() {
		convs := JsonConverters()
		obj	  := [
			"name"	: "Jeff",
			"_type"	: T_Entity06_Impl1#.qname,
		]

		// test null is null
		verifyEq(convs.fromJsonVal(null), null)

		// test Json literals pass through
		verifyEq(convs.fromJsonVal( 69 ),  69 )
		verifyEq(convs.fromJsonVal( 69f),  69f)
		verifyEq(convs.fromJsonVal("69"), "69")
		verifyEq(convs.fromJsonVal([69]), [69])
		verifyEq(convs.fromJsonVal(["num":69]), Str:Obj?["num":69])

		// look Mum, no type arg!
		verifyEq(convs.fromJsonVal(obj)?.typeof, T_Entity06_Impl1#)

		// meh - MimeType is not BSON
		verifyErrMsg(ArgErr#, "Do not know how to convert JSON val, please supply a fantomType arg - sys::MimeType") {
			convs.fromJsonVal(MimeType("wot/ever"))
		}
		
		// DANGER - now let's try nested Objs!
		verifyEq(convs.fromJsonVal([ 69,  obj])->get(  -1 )->typeof, T_Entity06_Impl1#)
		verifyEq(convs.fromJsonVal(["obj":obj])->get("obj")->typeof, T_Entity06_Impl1#)
		
		// this should work, even if we stipulate objects
		verifyEq(convs.fromJsonVal([ 69,  obj], Obj[]#    )->get(  -1 )->typeof, T_Entity06_Impl1#)
		verifyEq(convs.fromJsonVal(["obj":obj], [Str:Obj]#)->get("obj")->typeof, T_Entity06_Impl1#)
	}
	
	Void testDoNotWriteNulls() {
		convs	:= JsonConverters(null, ["doNotWriteNulls":true])
		obj		:= convs.toJson(T_Entity04 {
			obj1 = "me"
			obj2 = null
			obj3 = 69
			obj4 = null
		})
		
		verifyEq(obj, """{"obj1":"me","obj3":69}""")
	}
}

@Js
internal class T_Entity04 {
	@JsonProperty	Obj? obj1
	@JsonProperty	Obj? obj2
	@JsonProperty	Obj? obj3
	@JsonProperty	Obj? obj4

	// T_Entity04 also tests that entities can be created *without* an it-block ctor - which requires afBeanUtils::BeanBuilder
}

@Js
internal class T_Entity02 {
	@JsonProperty	Obj? obj1
	@JsonProperty	Buf? obj2
}
