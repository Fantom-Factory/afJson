
@Js
internal class JsonTest : Test {
	
	Json json := Json()
	JsonTypeInspectors	inspectors	:= JsonTypeInspectors()
	EntityConverter		converter	:= EntityConverter(inspectors)

}
