
@Js internal const class JsonNumConverter : JsonConverter {
	
	override Obj? toJsonVal(Obj? fantomObj, JsonConverterCtx ctx) { fantomObj }

	override Obj? fromJsonVal(Obj? jsonVal, JsonConverterCtx ctx) {
		if (jsonVal == null) return null
		
		if (ctx.type.fits(Num#) && jsonVal is Num) {
			if (ctx.type.toNonNullable == Int#) 
				return ((Num) jsonVal).toInt
			if (ctx.type.toNonNullable == Float#) 
				return ((Num) jsonVal).toFloat
			if (ctx.type.toNonNullable == Decimal#) 
				return ((Num) jsonVal).toDecimal
		}
		
		return jsonVal
	}
}
