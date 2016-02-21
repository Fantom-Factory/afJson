
@NoDoc	// advanced use only
const class JsonModule {
	
	Str:Obj nonInvasiveIocModule() {
		[
			"services"	: [
				[
					"id"	: Json#.qname,
					"type"	: Json#,
				],
				[
					"id"	: JsonTypeInspectors#.qname,
					"type"	: JsonTypeInspectors#,
				],
				[
					"id"	: JsonReader#.qname,
					"type"	: JsonReader#,
				],
				[
					"id"	: JsonWriter#.qname,
					"type"	: JsonWriter#,
				]
			],

			"contributions" : [
				[
					"serviceId"	: JsonTypeInspectors#.qname,
					"key"		: "afJson.literal",
					"value"		: LiteralInspector()
				],
				[
					"serviceId"	: JsonTypeInspectors#.qname,
					"key"		: "afJson.map",
					"after"		: "afJson.literal",
					"value"		: NamedInspector(Map#, MapConverter())
				],
				[
					"serviceId"	: JsonTypeInspectors#.qname,
					"key"		: "afJson.list",
					"after"		: "afJson.map",
					"value"		: NamedInspector(List#, ListConverter())
				],
				[
					"serviceId"	: JsonTypeInspectors#.qname,
					"key"		: "afJson.type",
					"after"		: "afJson.list",
					"value"		: NamedInspector(Type#, TypeConverter())
				],
				[
					"serviceId"	: JsonTypeInspectors#.qname,
					"key"		: "afJson.slot",
					"after"		: "afJson.type",
					"value"		: NamedInspector(Slot#, SlotConverter())
				],
				[
					"serviceId"	: JsonTypeInspectors#.qname,
					"key"		: "afJson.method",
					"after"		: "afJson.slot",
					"value"		: NamedInspector(Method#, SlotConverter())
				],
				[
					"serviceId"	: JsonTypeInspectors#.qname,
					"key"		: "afJson.field",
					"after"		: "afJson.method",
					"value"		: NamedInspector(Field#, SlotConverter())
				],
				[
					"serviceId"	: JsonTypeInspectors#.qname,
					"key"		: "afJson.serializable",
					"after"		: "afJson.field",
					"value"		: SerializableInspector()
				],
				[
					"serviceId"	: JsonTypeInspectors#.qname,
					"key"		: "afJson.obj",
					"after"		: "afJson.serializable",
					"value"		: ObjInspector()
				]
			]
		]
	}	
}
