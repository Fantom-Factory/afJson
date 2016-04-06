
internal class TestJsDates : JsonTest {

	Void testJsDates() {
		jsonService := Json(JsonTypeInspectors(
			JsonTypeInspectors.defaultInspectors.insert(0, T_DateInspector())
		))
		
		user := T_User04 { name = "Judge Dredd"; timestamp = DateTime.now }
		json := jsonService.writeJson(user, T_User04#)
		
		echo(json) // --> {"name":"Judge Dredd","timestamp":"new Date(1456178248297)"}
	}
}

internal class T_User04 {
	@JsonProperty Str? 		name
	@JsonProperty DateTime?	timestamp
}

internal const class T_DateInspector : JsonTypeInspector {
	// this is a public, but @NoDoc'ed class in afJson
	const JsonConverter converter := JsDateConverter()
	
	override JsonTypeMeta? inspect(Type type, JsonTypeInspectors inspectors) {
		type.toNonNullable == DateTime# ? JsonTypeMeta { it.type = type; it.converter = this.converter } : null
	}
}

internal const class JsDateConverter : JsonConverter {

	override Obj? toJsonObj(JsonConverterCtx ctx, Obj? fantomObj)	{
		fantomObj == null ? null : JsLiteral("new Date(${((DateTime) fantomObj).toJava})")
	}

	override Obj? toFantom(JsonConverterCtx ctx, Obj? jsonObj) { throw UnsupportedErr() }
}