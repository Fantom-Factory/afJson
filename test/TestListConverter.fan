
internal class TestListConverter : Test {
	
	Void testToJson() {
		ent := T_Entity12() { list = [T_Entity08_Enum.wot, T_Entity08_Enum.ever] }
		doc := JsonConverters().toJsonObj(ent)
		map := (Obj[]) doc["list"]

		verifyEq(map[0], "wot")
		verifyEq(map[1], "ever")
	}

	Void testFromJson() {
		doc := ["list":["wot", "ever"]]
		ent := (T_Entity12) JsonConverters().fromJsonObj(doc, T_Entity12#)

		verifyEq(ent.list.of, T_Entity08_Enum#)
		verifyEq(ent.list[0], T_Entity08_Enum.wot )
		verifyEq(ent.list[1], T_Entity08_Enum.ever)
	}

	Void testNullStrategy() {
		obj := JsonConverters().fromJsonObj(null, Int?[]?#)
		verifyNull(obj)
	}
}

internal class T_Entity12 {
	@JsonProperty T_Entity08_Enum[]? list
	new make(|This|? in := null) { in?.call(this) }
}
