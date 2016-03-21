
@Js
internal class TestPrettyPrint : JsonTest {
	
	JsonWriter	jsonWriter	:= JsonWriter(true)

	Void testBool() {
		json := jsonWriter.writeObj(true)
		verifyEq("true", json)
	}

	Void testInt() {
		json := jsonWriter.writeObj(68)
		verifyEq("68", json)
	}

	Void testFloat() {
		json := jsonWriter.writeObj(68.0f)
		verifyEq("68.0", json)
	}

	Void testNull() {
		json := jsonWriter.writeObj(null)
		verifyEq("null", json)
	}

	Void testStr() {
		json := jsonWriter.writeObj("Dude")
		verifyEq("\"Dude\"", json)
	}

	Void testNarrowList() {
		json := jsonWriter.writeObj([1, 2, 3], PrettyPrintOptions { it.maxWidth=5; it.indent="\t" })
		verifyEq("[
		          	1,
		          	2,
		          	3
		          ]", json)
	}

	Void testWideList() {
		json := jsonWriter.writeObj([1, 2, 3])
		verifyEq("[1, 2, 3]", json)		
	}

	Void testNarrowMap() {
		map	 := [:] { ordered=true }.add("1", 1).add("2", 2).add("3", 3)
		json := jsonWriter.writeObj(map, PrettyPrintOptions { it.maxWidth=5; it.indent="\t" })
		verifyEq("""{
		            	"1" : 1,
		            	"2" : 2,
		            	"3" : 3
		            }""", json)
	}

	Void testWideMap() {
		map	 := [:] { ordered=true }.add("1", 1).add("2", 2).add("3", 3)
		json := jsonWriter.writeObj(map)
		verifyEq("""{"1": 1, "2": 2, "3": 3}""", json)		
	}

	Void testMapKeyValIndenting() {
		map	 := [:] { ordered=true }.add("1-", 1).add("2--", 2).add("3---", 3).add("4----", 4).add("5-----", 5)
		json := jsonWriter.writeObj(map, PrettyPrintOptions { it.maxWidth=5; it.indent="    " })
		verifyEq("""{
		                "1-"     : 1,
		                "2--"    : 2,
		                "3---"   : 3,
		                "4----"  : 4,
		                "5-----" : 5
		            }""", json)
	}

	Void testListOfMaps() {
		map	 := 
		[
			[:] { ordered=true }
				.add("key1", "ever")
				.add("key2", "ever")
			,
			[
				"wot"	: "ever",
			],
		]
		json := jsonWriter.writeObj(map, PrettyPrintOptions { it.maxWidth=5; it.indent="    " })
		verifyEq(
"""[
       {
           "key1" : "ever",
           "key2" : "ever"
       },
       {
           "wot" : "ever"
       }
   ]""", json)
	}

	Void testMapOfMaps() {
		map	 := 
		[:] { ordered=true }
			.add("key1", [:] { ordered=true }
				.add("key1", [:] { ordered=true }
					.add("key1", "ever")
					.add("key2", "ever")
				)
				.add("key2", "ever")
			)
			.add("key2",[
				"wot"	: "ever",
			])

		json := jsonWriter.writeObj(map, PrettyPrintOptions { it.maxWidth=5; it.indent="    " })
		verifyEq(
"""{
       "key1" : {
           "key1" : {
               "key1" : "ever",
               "key2" : "ever"
           },
           "key2" : "ever"
       },
       "key2" : {
           "wot" : "ever"
       }
   }""", json)
	}
}
