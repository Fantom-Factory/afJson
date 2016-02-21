
@Js
internal class TestJsonConversion : JsonTest {
	
	private DateTime now	:= DateTime.now
	
	Void testConversion() {
		// units are defined in JS
		if (Unit.fromStr("pH", false) == null)
			Unit.define("pH")
		
		entity := T_Entity01() {
			
			// JSON literals			
			float 		= 69.0f
			str 		= "string"
			doc			= ["wot":"ever"]
			list		= ["wot","ever"]
			bool		= true
			nul			= null
			int 		= 999
			map			= [3:T_Entity01_Enum.ever]
			
			// Fantom literals
			regex		= "2 problems".toRegex
			dateTime	= now
			date		= Date.today
			enumm		= T_Entity01_Enum.wot
			uri			= `http://uri`
			decimal		= 6.9d
			duration	= 3sec
			type		= TestJsonConversion#
			slot		= TestJsonConversion#testConversion
			range		= (2..<4)
			
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
		fanObj := inspectors.toJson(entity, T_Entity01#)
		entity = inspectors.toFantom(fanObj, T_Entity01#)
		
		// JSON types
		verifyEq(entity.float, 		69f)
		verifyEq(entity.str, 		"string")
		verifyEq(entity.doc["wot"],	"ever")
		verifyEq(entity.list[0], 	"wot")
		verifyEq(entity.list[1], 	"ever")
		verifyEq(entity.bool, 		true)
		verifyEq(entity.nul, 		null)
		verifyEq(entity.int,		999)
		verifyEq(entity.map[3],		T_Entity01_Enum.ever)
		
		// Fantom types
		verifyEq(entity.regex, 		"2 problems".toRegex)
		verifyEq(entity.dateTime,	now)
		verifyEq(entity.date, 		Date.today)	
		verifyEq(entity.enumm,		T_Entity01_Enum.wot)
		verifyEq(entity.uri,		`http://uri/`)
		verifyEq(entity.decimal,	6.9d)
		verifyEq(entity.duration,	3sec)
		verifyEq(entity.type,		TestJsonConversion#)
		verifyEq(entity.slot,		TestJsonConversion#testConversion)
		verifyEq(entity.range,		2..<4)

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

@Js
internal class T_Entity01 {

	// JSON Literals
	@JsonProperty	Float		float
	@JsonProperty	Str			str
	@JsonProperty	Str:Str?	doc
	@JsonProperty	Str?[]		list
	@JsonProperty	Bool?		bool
	@JsonProperty	Obj?		nul
	@JsonProperty	Int?		int
	@JsonProperty	Int:T_Entity01_Enum?	map
	
	// Fantom literals
	@JsonProperty	Regex		regex
	@JsonProperty	DateTime?	dateTime
	@JsonProperty	Date		date
	@JsonProperty	T_Entity01_Enum	enumm
	@JsonProperty	Uri			uri
	@JsonProperty	Decimal		decimal
	@JsonProperty	Duration	duration
	@JsonProperty	Type		type
	@JsonProperty	Slot		slot
	@JsonProperty	Range		range
	
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

@Js
internal enum class T_Entity01_Enum {
	wot, ever;
}
