class_name EffectLoader
extends RefCounted


static func load_effects(registry: EffectRegistry, file_path: String) -> void:
	var data: Variant = JsonLoader.load_json(file_path)

	if data == null:
		push_error("EffectLoader: Failed to load effects from '%s'" % file_path)
		return

	if not data is Dictionary:
		push_error("EffectLoader: Invalid data format in '%s'" % file_path)
		return

	if not data.has("effects"):
		push_error("EffectLoader: Missing 'effects' key in '%s'" % file_path)
		return

	var effects_data: Array = data["effects"]
	if not effects_data is Array:
		push_error("EffectLoader: 'effects' must be an array in '%s'" % file_path)
		return

	for effect_data in effects_data:
		if not effect_data is Dictionary:
			push_error("EffectLoader: Invalid effect data in '%s'" % file_path)
			continue

		var effect: EffectDefinition = EffectDefinition.from_dictionary(effect_data)
		registry.register(effect)
