using build

class Build : BuildPod {

	new make() {
		podName = "afJson"
		summary = "A JSON to Fantom object mapping library"
		version = Version("0.0.4")

		meta = [
			"proj.name"		: "Json",
			"afIoc.module"	: "afJson::JsonModule",
			"repo.internal"	: "true",
			"repo.tags"		: "system, web",
			"repo.public"	: "true"
		]

		depends = [
			"sys 1.0.67 - 1.0",
			
			"concurrent 1.0",
			// ---- Core ------------------------
			"afBeanUtils  1.0.8  - 1.0",	// for afBeanUtils::BeanFactory
			"afConcurrent 1.0.10 - 1.0",	// for afConcurrent::AtomicMap
			
		]

		srcDirs = [`fan/`, `fan/internal/`, `fan/internal/converters/`, `fan/internal/inspectors/`, `fan/public/`, `test/`]
		resDirs = [`doc/`]

		docApi = true
		docSrc = true
	}
}
