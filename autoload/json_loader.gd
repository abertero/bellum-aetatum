extends Node


func load_json(path: String) -> Variant:
	if not FileAccess.file_exists(path):
		push_error("JsonLoader: file not found: %s" % path)
		return null

	var file := FileAccess.open(path, FileAccess.READ)
	var json_string: String = file.get_as_text()
	file.close()

	var json := JSON.new()
	var error: Error = json.parse(json_string)
	if error != OK:
		push_error("JsonLoader: parse error in %s: %s" % [path, json.get_error_message()])
		return null

	return json.data
