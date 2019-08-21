
internal class TestObjConverter : Test {
	
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
}

internal class T_Entity11 {
	@JsonProperty T_Entity11_Name name	:= T_Entity11_Name()
	new make(|This|? in := null) { in?.call(this) }
}

internal class T_Entity11_Name {
	@JsonProperty Str name	:= "Dredd"
	@JsonProperty Int badge	:= 69
	new make(|This|? in := null) { in?.call(this) }
}
