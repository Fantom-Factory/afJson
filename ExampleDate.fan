using afJson

class User {
    @JsonProperty Str?      name
    @JsonProperty DateTime? timestamp
}

class Example {
    Void main() {
        jsonService := Json(JsonTypeInspectors(
            JsonTypeInspectors.defaultInspectors.insert(0, JsDateInspector())
        ))
        
        user := User { name = "Judge Dredd"; timestamp = DateTime.now }
        json := jsonService.writeEntity(user)
        
        echo(json) // --> {"name":"Judge Dredd","timestamp":"new Date(1456178248297)"}
    }
}

const class JsDateInspector : JsonTypeInspector {
    const JsonConverter converter := JsDateConverter()
    
    override JsonTypeMeta? inspect(Type type, JsonTypeInspectors inspectors) {
        type.toNonNullable == DateTime# ? JsonTypeMeta { it.type = type; it.converter = this.converter } : null
    }
}

const class JsDateConverter : JsonConverter {
    override Obj? toFantom(JsonConverterCtx ctx, Obj? jsonObj) { throw UnsupportedErr() }

    override Obj? toJsonObj(JsonConverterCtx ctx, Obj? fantomObj) {
        fantomObj == null ? null : JsLiteral("new Date(${((DateTime) fantomObj).toJava})")
    }
}
