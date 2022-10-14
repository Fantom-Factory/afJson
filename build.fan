using build

class Build : BuildPod {

	new make() {
		podName = "afJson"
		summary = "A JSON to Fantom object mapping library"
		version = Version("2.0.15")

		meta = [
			"pod.dis"		: "Json",
			//"afIoc.module"	: "afJson::JsonModule",
			"repo.tags"		: "system, web",
			"repo.public"	: "true",
			
			// ---- SkySpark ----
			"ext.name"		: "afJson",
			"ext.icon"		: "afJson",
			"ext.depends"	: "afBeanUtils, afConcurrent",
			"skyarc.icons"	: "true",
		]

		index	= [
			"skyarc.ext"	: "afJson"
		]

		depends = [
			// ---- Fantom Core -----------------
			"sys          1.0.73 - 1.0",

			// ---- Fantom Factory --------------
			"afBeanUtils  1.0.12 - 1.0",	// for afBeanUtils::TypeCoercer & BeanBuilder
			"afConcurrent 1.0.26 - 1.0",	// for afConcurrent::AtomicMap
		]

		srcDirs = [`fan/`, `fan/advanced/`, `fan/internal/`, `fan/internal/converters/`, `test/`]
		resDirs = [`doc/`, `svg/`]

		docApi = true
		docSrc = true
		
		meta["afBuild.uberPod"]	= "afConcurrent/AtomicMap afConcurrent/ConcurrentUtils afBeanUtils/BeanBuilder afBeanUtils/TypeCoercer afBeanUtils/TypeLookup afBeanUtils/ArgNotFoundErr afBeanUtils/NotFoundErr afBeanUtils/ReflectUtils"
	}
}
