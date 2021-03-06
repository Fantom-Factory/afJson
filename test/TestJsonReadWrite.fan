
@Js internal class TestJsonReadWrite : Test {

	JsonReader	jsonReader	:= JsonReader()
	JsonWriter	jsonWriter	:= JsonWriter()
	
	Void testBasics() {
		// basic scalars
		verifyBasics("null", null)
		verifyBasics("true", true)
		verifyBasics("false", false)

		// numbers
		verifyBasics("5", 5)
		verifyBasics("-1234", -1234)
		verifyBasics("23.48", 23.48f)
		verifyBasics("2.309e23", 2.309e23f)
		verifyBasics("-5.8e-15", -5.8e-15f)

		// strings
		verifyBasics(Str<|""|>, "")
		verifyBasics(Str<|"x"|>, "x")
		verifyBasics(Str<|"ab"|>, "ab")
		verifyBasics(Str<|"hello world!"|>, "hello world!")
		verifyBasics(Str<|"\" \\ \/ \b \f \n \r \t"|>, "\" \\ / \b \f \n \r \t")
		verifyBasics(Str<|"\u00ab \u0ABC \uabcd"|>, "\u00ab \u0ABC \uabcd")

		// arrays
		verifyBasics("[]", Obj?[,])
		verifyBasics("[1]", Obj?[1])
		verifyBasics("[1,2.0]", Obj?[1,2f])
		verifyBasics("[1,2,3]", Obj?[1,2,3])
		verifyBasics("[3, 4.0, null, \"hi\"]", [3, 4.0f, null, "hi"])
		verifyBasics("[2,\n3]", Obj?[2, 3])
		verifyBasics("[2\n,3]", Obj?[2, 3])
		verifyBasics("[	2 \n , \n 3 ]", Obj?[2, 3])

		// objects
		verifyBasics(Str<|{}|>, Str:Obj?[:])
		verifyBasics(Str<|{"k":null}|>, Str:Obj?["k":null])
		verifyBasics(Str<|{"a":1, "b":2}|>, Str:Obj?["a":1, "b":2])
		verifyBasics(Str<|{"a":1, "b":2,}|>, Str:Obj?["a":1, "b":2])

		// errors
		verifyErr(ParseErr#) { jsonReader.readJson("\""			) }
		verifyErr(ParseErr#) { jsonReader.readJson("["			) }
		verifyErr(ParseErr#) { jsonReader.readJson("[1"			) }
		verifyErr(ParseErr#) { jsonReader.readJson("[1,2"		) }
		verifyErr(ParseErr#) { jsonReader.readJson(" {"			) }
		verifyErr(ParseErr#) { jsonReader.readJson(""" {"x":"""	) }
		verifyErr(ParseErr#) { jsonReader.readJson(""" {"x":4,""") }
	}

	Void verifyBasics(Str s, Obj? expected) {
		// verify object stand alone
		verifyRoundtrip(expected)

		// wrap as [s]
		array := jsonReader.readJson("[$s]") as Obj?[]
		verifyType(array, Obj?[]#)
		verifyEq(array.size, 1)
		verifyEq(array[0], expected)
		verifyRoundtrip(array)

		// wrap as [s, s]
		array = jsonReader.readJson("[$s,$s]") as Obj?[]
		verifyType(array, Obj?[]#)
		verifyEq(array.size, 2)
		verifyEq(array[0], expected)
		verifyEq(array[1], expected)
		verifyRoundtrip(array)

		// wrap as {"key":s}
		map := jsonReader.readJson(" {\"key\":$s}") as Str:Obj?
		verifyType(map, Str:Obj?#)
		verifyEq(map.size, 1)
		verifyEq(map["key"], expected)
		verifyRoundtrip(map)
	}

	Void verifyRoundtrip(Obj? obj) {
		str := jsonWriter.writeJson(obj)
		roundtrip := jsonReader.readJson(str)
		verifyEq(obj, roundtrip)
	}

	Void testWrite() {
		// built-in scalars
		verifyWrite(null, Str<|null|>)
		verifyWrite(true, Str<|true|>)
		verifyWrite(false, Str<|false|>)
		verifyWrite("hi", Str<|"hi"|>)
		if (Env.cur.runtime == "js")	// both are valid JSON numbers
			verifyWrite(-2.3e34f, Str<|-2.3e+34|>)
		else
			verifyWrite(-2.3e34f, Str<|-2.3E34|>)
		verifyWrite(34.12345d, Str<|34.12345|>)

		// list/map sanity checks
		verifyWrite([1, 2, 3], Str<|[1,2,3]|>)
		verifyWrite(["key":"val"], Str<|{"key":"val"}|>)
		verifyWrite(["key":"val\\\"ue"], Str<|{"key":"val\\\"ue"}|>)

		// errors
		verifyErr(IOErr#) { verifyWrite(5min, "") }
		verifyErr(IOErr#) { verifyWrite(Buf(), "") }
		verifyErr(IOErr#) { verifyWrite(Str#.pod, "") }
	}

	Void verifyWrite(Obj? obj, Str expected) {
		verifyEq(jsonWriter.writeJson(obj), expected)
	}

	Void testRaw() {
		// make raw json
		buf := StrBuf.make
		buf.add("\n {\n	\"type\"\n:\n\"Foobar\",\n \n\n\"age\"\n:\n34,		\n\n\n\n")
		buf.add("\t\"nested\"\t:	\n {\t \"ids\":[3.28, 3.14, 2.14],	\t\t\"dead\":false\n\n,")
		buf.add("\t\n \"friends\"\t:\n null\t	\n}\n\t\n}")
		str := buf.toStr

		// parse
		Str:Obj? map := jsonReader.readJson(str)

		// verify
		verifyEq(map["type"], "Foobar")
		verifyEq(map["age"], 34)
		inner := (Str:Obj?) map["nested"]
		verifyNotEq(inner, null)
		verifyEq(inner["dead"], false)
		verifyEq(inner["friends"], null)
		list := (List)inner["ids"]
		verifyNotEq(list, null)
		verifyEq(list.size, 3)
		verifyEq(map["friends"], null)
	}

	Void testEscapes() {
		Str:Obj obj := jsonReader.readJson(
			Str<|{
			     "foo"		: "bar\nbaz",
			     "bar"		: "_\r \t \u0abc \\ \/_",
			     "baz"		: "\"hi\"",
			     "num"		: 1234,
			     "bool"		: true,
			     "float"	: 2.4,
			     "dollar"	: "$100 \u00f7",
			     "a\nb"		: "crazy key"
			     }|>)

		f := |->| {
			verifyEq(obj["foo"], "bar\nbaz")
			verifyEq(obj["bar"], "_\r \t \u0abc \\ /_")
			verifyEq(obj["baz"], Str<|"hi"|>)
			verifyEq(obj["num"], 1234)
			verifyEq(obj["bool"], true)
			verify(2.4f.approx(obj["float"]))
			verifyEq(obj["dollar"], "\$100 \u00f7")
			verifyEq(obj["a\nb"], "crazy key")
			verifyEq(obj.keys.join(","), "foo,bar,baz,num,bool,float,dollar,a\nb")
		}

		f()
		buf := Buf()
		jsonWriter.writeJsonToStream(obj, buf.out)
		obj = jsonReader.readJsonFromStream(buf.flip.in)
		f()
	}
	
	Void testJsLiterals() {
		json := jsonWriter.writeJson(["key":"Dude!"])
		verifyEq(json, "{\"key\":\"Dude!\"}")

		// Look! No Quotes!
		json = jsonWriter.writeJson(["key":JsLiteral("Dude!")])
		verifyEq(json, "{\"key\":Dude!}")
	}

	Void testUnicodeEscaping() {
		json := null as Str

		json = jsonWriter.writeJson("©opyright")
		verifyEq(json, Str<|"\u00a9opyright"|>)

		json = jsonWriter.writeJson("©opyright", ["escapeUnicode":false])
		verifyEq(json, Str<|"©opyright"|>)
	}
}
