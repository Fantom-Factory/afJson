using afJson

class User {
    @JsonProperty Str?      name
    @JsonProperty DateTime? timestamp
}

class Example {
    Void main() {
        jsonService := Json(JsonConverters.defConvs.setAll([
            Date# : JsDateConverter()
        ]))
        
        user := User { name = "Judge Dredd"; timestamp = DateTime.now }
        json := jsonService.toJson(user)
        
        echo(json) // --> {"name":"Judge Dredd","timestamp":"new Date(1456178248297)"}
    }
}

const class JsDateConverter : JsonConverter {
    override Obj? fromJsonVal(Obj? jsonVal, JsonConverterCtx ctx)  { throw UnsupportedErr() }
	
	override Obj? toJsonVal(Obj? fantomObj, JsonConverterCtx ctx) {
        fantomObj == null ? null : JsLiteral("new Date(${((DateTime) fantomObj).toJava})")
    }
}
