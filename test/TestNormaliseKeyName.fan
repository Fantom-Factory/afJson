
@Js internal class TestNormaliseKeyName : Test {
	
	Void testNormaliseDotNet() {
		verifyEq(normaliseInv(""),				"")
		verifyEq(normaliseInv("T"),				"t")
		verifyEq(normaliseInv("Text"),			"text")
		verifyEq(normaliseInv("TextIdx"),		"textIdx")
		verifyEq(normaliseInv("SWVersion"),		"swVersion")
		verifyEq(normaliseInv("CDFFormat"),		"cdfFormat")
		verifyEq(normaliseInv("UniqueID"),		"uniqueId")
		verifyEq(normaliseInv("AccLevelW"),		"accLevelW")
		verifyEq(normaliseInv("MegaVERIndex"),	"megaVerIndex")
		
		verifyEq(normaliseInv("UtilityITEMS.UtilityRecord"),	"utilityItems.utilityRecord")
	}

	Void testNormaliseSnake() {
		verifyEq(normaliseInv("amount_refunded"	),	"amountRefunded")
		verifyEq(normaliseInv("amount_REfunded"	),	"amountREfunded")
		verifyEq(normaliseInv("amount_REFunded"	),	"amountReFunded")
		verifyEq(normaliseInv("amount_REFUnded"	),	"amountRefUnded")
		verifyEq(normaliseInv("sw_Version"		),	"swVersion")
		verifyEq(normaliseInv("mega_VER_Index"	),	"megaVerIndex")
	}
		
	private Str normaliseInv(Str str) {
		JsonConverters._noramliseKeyName(str)
	}
}
