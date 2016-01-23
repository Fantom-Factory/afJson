using build

class Build : BuildPod {

	new make() {
		podName = "afJson"
		summary = "My Awesome Json Project"
		version = Version("0.0.1")

		meta = [
			"proj.name" : "Json"
		]

		depends = [
			"sys 1.0.67 - 1.0",
			
			// ---- Core ------------------------
			"afBeanUtils  1.0.8  - 1.0",
			"afConcurrent 1.0.12 - 1.0",
		]

		srcDirs = [`fan/`, `fan/internal/`, `fan/internal/converters/`, `fan/internal/inspectors/`, `fan/public/`, `fan/public/advanced/`, `test/`]
		resDirs = [,]

		docApi = true
		docSrc = true
	}
}
