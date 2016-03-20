
** JSON literals pass straight through, as there's nothing to convert!
@NoDoc @Js
const class LiteralConverter : JsonConverter {

	override Obj? toJsonObj(JsonConverterCtx ctx, Obj? fantomObj)	{ fantomObj }

	override Obj? toFantom(JsonConverterCtx ctx, Obj? jsonObj) {

		// ensure nums are converted to the correct sub-type
		type := ctx.meta.implType.toNonNullable
		if (type.fits(Num#) && jsonObj is Num) {
			if (type == Int#) 
				return ((Num) jsonObj).toInt
			if (type == Float#) 
				return ((Num) jsonObj).toFloat
			if (type == Decimal#) 
				return ((Num) jsonObj).toDecimal
		}
		
		return jsonObj
	}
}
