using build

class Build : BuildPod {

	new make() {
		podName = "afJson"
		summary = "A JSON to Fantom object mapping library"
		version = Version("0.0.1")

		meta = [
			"proj.name"		: "Json",
			"afIoc.module"	: "afJson::JsonModule",
			"repo.tags"		: "web",
			"repo.public"	: "false"
		]

		depends = [
			"sys 1.0.67 - 1.0",
			
			"concurrent 1.0",
			// ---- Core ------------------------
			"afBeanUtils  1.0.8  - 1.0",	// for afBeanUtils::BeanFactory
			"afConcurrent 1.0.10 - 1.0",	// for afConcurrent::AtomicMap
			
		]

		srcDirs = [`fan/`, `fan/internal/`, `fan/internal/converters/`, `fan/internal/inspectors/`, `fan/public/`, `test/`]
		resDirs = [,]

		docApi = true
		docSrc = true
	}
}
