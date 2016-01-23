
internal class TestJsonConversion : JsonTest {
	
	private DateTime now	:= DateTime.now
	
	Void testConversion() {
		entity := T_Entity01() {
			
			// Mongo literals			
			float 		= 69.0f
			str 		= "string"
			doc			= ["wot":"ever"]
			list		= ["wot","ever"]
			bool		= true
			dateTime	= now
			nul			= null
			regex		= "2 problems".toRegex
			int 		= 999
			
			// Fantom literals
			date		= Date.today
			enumm		= T_Entity01_Enum.wot
			uri			= `http://uri`
			decimal		= 6.9d
			duration	= 3sec
			type		= TestJsonConversion#
			slot		= TestJsonConversion#testConversion
			range		= (2..<4)
			map			= [3:T_Entity01_Enum.ever]
			
			// Moar Fantom classes
			field		= TestJsonConversion#now
			depend		= Depend("afIoc 2.0.6 - 2.0")
			locale		= Locale("en-GB")
			method		= TestJsonConversion#testConversion
			mimeType	= MimeType("text/plain")
			time		= Time(2, 22, 22, 22)
			timeZone	= TimeZone.utc
			unit		= Unit("pH")
			uuid		= Uuid("03f0e2bb-8f1a-c800-e1f8-00623f7473c4")
			version		= Version([6, 9, 6, 9])
		}

		// perform round trip conversion
		fanObj := json.toJson(entity, T_Entity01#)
		entity = json.toFantom(fanObj, T_Entity01#)
		
		// Mongo types
		verifyEq(entity.float, 		69f)
		verifyEq(entity.str, 		"string")
		verifyEq(entity.doc["wot"],	"ever")
		verifyEq(entity.list[0], 	"wot")
		verifyEq(entity.list[1], 	"ever")
		verifyEq(entity.bool, 		true)
		verifyEq(entity.dateTime,	now)
		verifyEq(entity.nul, 		null)
		verifyEq(entity.regex, 		"2 problems".toRegex)
		verifyEq(entity.int,		999)
		
		// Fantom types
		verifyEq(entity.date, 		Date.today)	
		verifyEq(entity.enumm,		T_Entity01_Enum.wot)
		verifyEq(entity.uri,		`http://uri/`)
		verifyEq(entity.decimal,	6.9d)
		verifyEq(entity.duration,	3sec)
		verifyEq(entity.type,		TestJsonConversion#)
		verifyEq(entity.slot,		TestJsonConversion#testConversion)
		verifyEq(entity.range,		2..<4)
		verifyEq(entity.map[3],		T_Entity01_Enum.ever)

		// Moar Fantom classes
		verifyEq(entity.field,		TestJsonConversion#now)
		verifyEq(entity.depend,		Depend("afIoc 2.0.6 - 2.0"))
		verifyEq(entity.locale,		Locale("en-GB"))
		verifyEq(entity.method,		TestJsonConversion#testConversion)
		verifyEq(entity.mimeType,	MimeType("text/plain"))
		verifyEq(entity.time,		Time(2, 22, 22, 22))
		verifyEq(entity.timeZone,	TimeZone.utc)
		verifyEq(entity.unit,		Unit("pH"))
		verifyEq(entity.uuid,		Uuid("03f0e2bb-8f1a-c800-e1f8-00623f7473c4"))
		verifyEq(entity.version,	Version([6, 9, 6, 9]))

	}
}

internal class T_Entity01 {

	// JSON Literals
	@JsonProperty	Float		float
	@JsonProperty	Str			str
	@JsonProperty	Str:Str?	doc
	@JsonProperty	Str?[]		list
	@JsonProperty	Bool?		bool
	@JsonProperty	DateTime?	dateTime
	@JsonProperty	Obj?		nul
	@JsonProperty	Regex		regex
	@JsonProperty	Int?		int
	
	// Fantom literals
	@JsonProperty	Date		date
	@JsonProperty	T_Entity01_Enum	enumm
	@JsonProperty	Uri			uri
	@JsonProperty	Decimal		decimal
	@JsonProperty	Duration	duration
	@JsonProperty	Type		type
	@JsonProperty	Slot		slot
	@JsonProperty	Range		range
	@JsonProperty	Int:T_Entity01_Enum?	map
	
	// Moar Fantom Classes
	@JsonProperty	Field?		field
	@JsonProperty	Depend?		depend
	@JsonProperty	Locale?		locale
	@JsonProperty	Method?		method
	@JsonProperty	MimeType?	mimeType
	@JsonProperty	Time?		time
	@JsonProperty	TimeZone?	timeZone
	@JsonProperty	Unit?		unit
	@JsonProperty	Uuid?		uuid
	@JsonProperty	Version?	version
	
	new make(|This|in) { in(this) }
}

internal enum class T_Entity01_Enum {
	wot, ever;
}
