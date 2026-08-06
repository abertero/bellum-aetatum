class_name AILoader
extends RefCounted


static func load_personalities(registry: AIRegistry, file_path: String) -> void:
	var data: Variant = JsonLoader.load_json(file_path)

	if data == null:
		push_error("AILoader: Failed to load personalities from '%s'" % file_path)
		return

	if not data is Dictionary:
		push_error("AILoader: Invalid data format in '%s'" % file_path)
		return

	if not data.has("personalities"):
		push_error("AILoader: Missing 'personalities' key in '%s'" % file_path)
		return

	var personalities_data: Array = data["personalities"]
	if not personalities_data is Array:
		push_error("AILoader: 'personalities' must be an array in '%s'" % file_path)
		return

	for personality_data in personalities_data:
		if not personality_data is Dictionary:
			push_error("AILoader: Invalid personality data in '%s'" % file_path)
			continue

		var personality: AIPersonalityDefinition = AIPersonalityDefinition.from_dictionary(personality_data)
		registry.register(personality)
