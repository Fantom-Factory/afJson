
@Js internal class TestObjConverter : Test {
	
	Void testToJson() {
		ent := T_Entity11()
		obj := JsonConverters().toJsonObj(ent)

		map := (Str:Obj?) obj["name"]
		verifyEq(map["name"], "Dredd")
		verifyEq(map["badge"], 69)
	}

	Void testFromJson() {
		obj := ["name":["name":"Dredd", "badge":69]]
		ent := (T_Entity11) JsonConverters().fromJsonObj(obj, T_Entity11#)
		
		verifyEq(ent.name.name, "Dredd")
		verifyEq(ent.name.badge, 69)
	}

	Void testStrictMode() {
		obj := ["name":["name":"Dredd", "badge":69, "ammo":"hi-ex"]]
		verifyErrMsg(Err#, "Extraneous data in JSON object for afJson::T_Entity11_Name: ammo") {
			JsonConverters(null, ["afJson.strictMode":true]).fromJsonObj(obj, T_Entity11#)
		}
	}
	
	Void testDynamicType() {
		ent := T_Entity05 {
			it.impl1 = T_Entity06_Impl1()
			it.impl2 = T_Entity06_Impl2()
		}
		obj := JsonConverters().toJsonObj(ent)
		
		rebirth := (T_Entity05) JsonConverters().fromJsonObj(obj, T_Entity05#)
		
		verifyEq(rebirth.impl1->name, "Dredd")
		verifyEq(rebirth.impl2->name, "Death")
	}
}

@Js internal class T_Entity11 {
	@JsonProperty T_Entity11_Name name	:= T_Entity11_Name()
	new make(|This|? in := null) { in?.call(this) }
}
@Js internal class T_Entity11_Name {
	@JsonProperty Str name	:= "Dredd"
	@JsonProperty Int badge	:= 69
	new make(|This|? in := null) { in?.call(this) }
}

@Js internal class T_Entity05 {
	@JsonProperty T_Entity06 impl1
	@JsonProperty T_Entity06 impl2
	new make(|This|? in := null) { in?.call(this) }
}
@Js internal mixin T_Entity06 { }
@Js internal class T_Entity06_Impl1 : T_Entity06 {
	@JsonProperty Type _type	:= typeof
	@JsonProperty Str	name	:= "Dredd"
	new make(|This|? in := null) { in?.call(this) }
}
@Js internal class T_Entity06_Impl2 : T_Entity06 {
	@JsonProperty Type _type	:= typeof
	@JsonProperty Str	name	:= "Death"
	new make(|This|? in := null) { in?.call(this) }
}
