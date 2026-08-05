class_name AbilityLoader
extends RefCounted


static func load_abilities(registry: AbilityRegistry, file_path: String) -> void:
	var data: Variant = JsonLoader.load_json(file_path)

	if data == null:
		push_error("AbilityLoader: Failed to load abilities from '%s'" % file_path)
		return

	if not data is Dictionary:
		push_error("AbilityLoader: Invalid data format in '%s'" % file_path)
		return

	if not data.has("abilities"):
		push_error("AbilityLoader: Missing 'abilities' key in '%s'" % file_path)
		return

	var abilities_data: Array = data["abilities"]
	if not abilities_data is Array:
		push_error("AbilityLoader: 'abilities' must be an array in '%s'" % file_path)
		return

	for ability_data in abilities_data:
		if not ability_data is Dictionary:
			push_error("AbilityLoader: Invalid ability data in '%s'" % file_path)
			continue

		var ability: AbilityDefinition = AbilityDefinition.from_dictionary(ability_data)
		registry.register(ability)
