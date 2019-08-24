using build

class Build : BuildPod {

	new make() {
		podName = "afJson"
		summary = "A JSON to Fantom object mapping library"
		version = Version("2.0.0")

		meta = [
			"pod.dis"		: "Json",
			"afIoc.module"	: "afJson::JsonModule",
			"repo.internal"	: "true",
			"repo.tags"		: "system, web",
			"repo.public"	: "false"
		]

		depends = [
			"sys        1.0.71 - 1.0",
			"concurrent 1.0.71 - 1.0",

			// ---- Core ------------------------
			"afBeanUtils  1.0.10 - 1.0",	// for afBeanUtils::TypeCoercer & BeanBuilder
			"afConcurrent 1.0.22 - 1.0",	// for afConcurrent::AtomicMap
			
		]

		srcDirs = [`fan/`, `fan/internal/`, `fan/internal/converters/`, `test/`]
		resDirs = [`doc/`]

		docApi = true
		docSrc = true
	}
}
