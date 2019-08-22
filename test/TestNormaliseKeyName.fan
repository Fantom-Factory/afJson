
internal class TestNormaliseKeyName : Test {
	
	Void testNormalise() {
		verifyEq(normaliseInv("Text"),			"text")
		verifyEq(normaliseInv("TextIdx"),		"textIdx")
		verifyEq(normaliseInv("SWVersion"),		"swVersion")
		verifyEq(normaliseInv("CDFFormat"),		"cdfFormat")
		verifyEq(normaliseInv("UniqueID"),		"uniqueId")
		verifyEq(normaliseInv("AccLevelW"),		"accLevelW")
		verifyEq(normaliseInv("MegaVERIndex"),	"megaVerIndex")
	}
	
	private Str normaliseInv(Str str) {
		JsonConverters._noramliseKeyName(str)
	}
}
