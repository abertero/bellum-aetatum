class_name GameModeLoader
extends RefCounted


static func load_game_modes(file_path: String) -> Array[GameModeDefinition]:
	var result: Array[GameModeDefinition] = []
	var data: Variant = JsonLoader.load_json(file_path)

	if data == null or not data is Dictionary:
		return result

	if not data.has("game_modes"):
		return result

	var modes_data: Variant = data["game_modes"]
	if not modes_data is Array:
		return result

	for mode_data in modes_data:
		if mode_data is Dictionary:
			var mode: GameModeDefinition = GameModeDefinition.from_dictionary(mode_data)
			result.append(mode)

	return result
