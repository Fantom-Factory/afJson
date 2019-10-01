
@Js internal class TestMapConverter : Test {
	
	Void testToJson() {
		ent := T_Entity13()
		ent.vals = [:]
		ent.vals[6] = T_Entity08_Enum.wot
		ent.vals[9] = T_Entity08_Enum.ever

		rec := (Str:Obj?) JsonConverters().toJsonVal(ent, T_Entity13#)

		map := (Str:Obj?) rec["vals"]
		verifyEq(map["6"], "wot")
		verifyEq(map["9"], "ever")
	}

	Void testFromJson() {
		rec := ["vals":["6":"wot", "9":"ever"]]
		ent := (T_Entity13) JsonConverters().fromJsonObj(rec, T_Entity13#)
		
		verifyEq(ent.vals[6], T_Entity08_Enum.wot)
		verifyEq(ent.vals[9], T_Entity08_Enum.ever)
	}

	Void testNullStrategy_null() {
		obj := JsonConverters().fromJsonObj(null, [Int:Str?]?#)
		verifyNull(obj)
	}

	Void testKeyConvertErr() {
		badMap	:= [Err():"wotever"]
		verifyErrMsg(Err#, "Unsupported Map key type 'sys::Err', cannot coerce from Str#") {
			JsonConverters().toJsonVal(badMap, Map#) 
		}
	}
}

@Js internal class T_Entity13 {
	@JsonProperty [T_Entity08_Enum:Int]? keys
	@JsonProperty [Int:T_Entity08_Enum]? vals
	new make(|This|? in := null) { in?.call(this) }
}
