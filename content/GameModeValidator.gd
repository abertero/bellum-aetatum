class_name GameModeValidator
extends DefinitionValidator

var _game_modes: Array[GameModeDefinition] = []
var _file_path: String = ""


func initialize(game_modes: Array[GameModeDefinition], file_path: String) -> void:
	_game_modes = game_modes
	_file_path = file_path


func get_definition_type() -> String:
	return "GameMode"


func validate(context: ValidationContext) -> Array[ContentDiagnostic]:
	var diagnostics: Array[ContentDiagnostic] = []
	var seen_ids: Dictionary = {}

	for game_mode in _game_modes:
		_validate_game_mode(game_mode, context, seen_ids, diagnostics)

	return diagnostics


func _validate_game_mode(
	game_mode: GameModeDefinition,
	context: ValidationContext,
	seen_ids: Dictionary,
	diagnostics: Array[ContentDiagnostic]
) -> void:
	if game_mode.id == "":
		diagnostics.append(ContentDiagnostic.create_error(
			"(unknown)", "GameMode", "GameMode has empty id", _file_path, -1,
			"Add a unique id to the game mode definition"
		))
		return

	if seen_ids.has(game_mode.id):
		diagnostics.append(ContentDiagnostic.create_error(
			game_mode.id, "GameMode", "Duplicate game mode id", _file_path, -1,
			"Remove the duplicate game mode or change its id"
		))
		return

	seen_ids[game_mode.id] = true
	context.game_mode_ids.append(game_mode.id)
	_validate_game_mode_fields(game_mode, context, diagnostics)


func _validate_game_mode_fields(
	game_mode: GameModeDefinition,
	context: ValidationContext,
	diagnostics: Array[ContentDiagnostic]
) -> void:
	if game_mode.display_name == "":
		diagnostics.append(ContentDiagnostic.create_warning(
			game_mode.id, "GameMode", "GameMode has empty display_name", _file_path, -1,
			"Add a display name to the game mode"
		))

	if game_mode.default_ai_personality_id != "":
		context.game_mode_personality_refs[game_mode.id] = game_mode.default_ai_personality_id

	if game_mode.match_rules_path != "" and not ResourceLoader.exists(game_mode.match_rules_path):
		diagnostics.append(ContentDiagnostic.create_warning(
			game_mode.id, "GameMode", "Match rules file not found: %s" % game_mode.match_rules_path,
			_file_path, -1, "Add the match rules file or remove the reference"
		))

	if game_mode.stage_path != "" and not ResourceLoader.exists(game_mode.stage_path):
		diagnostics.append(ContentDiagnostic.create_warning(
			game_mode.id, "GameMode", "Stage file not found: %s" % game_mode.stage_path,
			_file_path, -1, "Add the stage file or remove the reference"
		))
