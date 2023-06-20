
@Js internal class TestLiteralConverters : Test {
	private DateTime now	:= DateTime.now

	Void testLiteralsToJson() {
		entity := T_Entity08() {
			
			// JSON literals
			bool		= true
			decimal		= 6.9d
			float		= 6.9f
			int			= 666
			literal		= JsLiteral("Dude!")
			nul			= null
			num			= 69f
			str			= "hello!"
			
			// Fantom types
			date		= Date.today
			dateTime	= now
			depend		= Depend("afAwesome 2.0+")
			duration	= 3sec
			enumm		= T_Entity08_Enum.wot
			field		= TestLiteralConverters#now
			locale		= Locale("en")
			method		= Test#setup
			mimeType	= MimeType("mime/type")
			range		= 2..<4
			regex		= "2 problems".toRegex
			slot		= Test#setup
			time		= Time(13, 14, 15)
			timeZone	= TimeZone.rel
			type		= Test[]?#
			unit		= Unit("°C")
			uri			= `http://wot ever/`
			uuid		= Uuid("088e6a43-3cd0-b300-62f7-c85b768bcc22")
			version		= Version("1.2.3.4")
		}
		
		jsonObj := JsonConverters().toJsonObj(entity)
		
		verifyEq(jsonObj["bool"],		entity.bool)
		verifyEq(jsonObj["decimal"],	entity.decimal)
		verifyEq(jsonObj["float"],		entity.float)
		verifyEq(jsonObj["int"],		entity.int)
		verifyEq(jsonObj["literal"],	entity.literal)
		verifyEq(jsonObj["num"],		entity.num)
		verifyEq(jsonObj["nul"],		null)
		verifyEq(jsonObj["str"],		entity.str)

		verifyEq(jsonObj["date"],		entity.date.toStr)
		verifyEq(jsonObj["dateTime"],	entity.dateTime.toStr)
		verifyEq(jsonObj["depend"],		entity.depend.toStr)
		verifyEq(jsonObj["duration"],	entity.duration.toStr)
		verifyEq(jsonObj["enumm"],		entity.enumm.toStr)
		verifyEq(jsonObj["field"],		entity.field.toStr)
		verifyEq(jsonObj["locale"],		entity.locale.toStr)
		verifyEq(jsonObj["method"],		entity.method.toStr)
		verifyEq(jsonObj["mimeType"],	entity.mimeType.toStr)
		verifyEq(jsonObj["range"],		entity.range.toStr)
		verifyEq(jsonObj["regex"],		entity.regex.toStr)
		verifyEq(jsonObj["slot"],		entity.slot.toStr)
		verifyEq(jsonObj["time"],		entity.time.toStr)
		verifyEq(jsonObj["timeZone"],	entity.timeZone.toStr)
		verifyEq(jsonObj["type"],		entity.type.toStr)
		verifyEq(jsonObj["unit"],		entity.unit.toStr)
		verifyEq(jsonObj["uri"],		"http://wot%20ever/")	// NOTE the percent encoding - done via Uri.encode()
		verifyEq(jsonObj["uuid"],		entity.uuid.toStr)
		verifyEq(jsonObj["version"],	entity.version.toStr)
	}
	
	Void testLiteralsFromJson() {
		jsonObj := [
			// JSON literals
			"bool"			: true,
			"decimal"		: 6.9d,
			"float"			: 69f,
			"int"			: 666,
			"literal"		: JsLiteral("Dude!"),
			"nul"			: null,
			"num"			: 69f,
			"str"			: "string",

			// Fantom types
			"date"			: Date.today.toStr,
			"dateTime"		: now.toStr,
			"depend"		: "afAwesome 2.0+",
			"duration"		: 3sec.toStr,
			"enumm"			: "wot",
			"field"			: TestLiteralConverters#now.qname,
			"locale"		: "en",
			"method"		: Test#setup.qname,
			"mimeType"		: "mime/type",
			"range"			: "2..<4",
			"regex"			: "2 problems",
			"slot"			: Test#setup.qname,
			"time"			: Time(13, 14, 15).toStr,
			"timeZone"		: "Etc/Rel",
			"type"			: "sys::Test[]?",
			"unit"			: "°C",
			"uri"			: "http://wot%20ever/",
			"uuid"			: "088e6a43-3cd0-b300-62f7-c85b768bcc22",
			"version"		: "1.2.3.4",
		]

		entity := (T_Entity08) JsonConverters().fromJsonObj(jsonObj, T_Entity08#)

		verifyEq(entity.bool,		jsonObj["bool"])
		verifyEq(entity.decimal,	jsonObj["decimal"])
		verifyEq(entity.float,		jsonObj["float"])
		verifyEq(entity.int,		jsonObj["int"])
		verifyEq(entity.literal,	jsonObj["literal"])
		verifyEq(entity.nul,		jsonObj["nul"])
		verifyEq(entity.num,		jsonObj["num"])
		verifyEq(entity.str,		jsonObj["str"])

		verifyEq(entity.date,		Date.today)
		verifyEq(entity.dateTime,	now)
		verifyEq(entity.depend,		Depend("afAwesome 2.0+"))
		verifyEq(entity.duration,	3sec)
		verifyEq(entity.enumm,		T_Entity08_Enum.wot)
		verifyEq(entity.field,		TestLiteralConverters#now)
		verifyEq(entity.locale,		Locale("en"))
		verifyEq(entity.method,		Test#setup)
		verifyEq(entity.mimeType,	MimeType("mime/type"))
		verifyEq(entity.range,		2..<4)
		verifyEq(entity.regex,		"2 problems".toRegex)
		verifyEq(entity.slot,		Test#setup)
		verifyEq(entity.time,		Time(13, 14, 15))
		verifyEq(entity.timeZone,	TimeZone.rel)
		verifyEq(entity.type,		Test[]?#)
		verifyEq(entity.unit,		Unit("°C"))
		verifyEq(entity.uri,		`http://wot ever/`)		// NOTE the space has been decoded
		verifyEq(entity.uuid,		Uuid("088e6a43-3cd0-b300-62f7-c85b768bcc22"))
		verifyEq(entity.version,	Version("1.2.3.4"))
	}
}

@Js internal class T_Entity08 {
	// JSON literals
	@JsonProperty	Bool		bool
	@JsonProperty	Decimal		decimal
	@JsonProperty	Float		float
	@JsonProperty	Int?		int
	@JsonProperty	JsLiteral	literal
	@JsonProperty	Num			num
	@JsonProperty	Obj?		nul
	@JsonProperty	Str			str
	
	// Fantom types
	@JsonProperty	Date		date
	@JsonProperty	DateTime	dateTime
	@JsonProperty	Depend?		depend
	@JsonProperty	Duration	duration
	@JsonProperty	T_Entity08_Enum	enumm
	@JsonProperty	Field?		field
	@JsonProperty	Locale?		locale
	@JsonProperty	Method?		method
	@JsonProperty	MimeType?	mimeType
	@JsonProperty	Range		range
	@JsonProperty	Regex		regex
	@JsonProperty	Slot		slot
	@JsonProperty	Time		time
	@JsonProperty	TimeZone?	timeZone
	@JsonProperty	Type		type
	@JsonProperty	Unit?		unit
	@JsonProperty	Uri			uri
	@JsonProperty	Uuid?		uuid
	@JsonProperty	Version?	version
	
	new make(|This|in) { in(this) }
}

@Js internal enum class T_Entity08_Enum {
	wot, ever;
}