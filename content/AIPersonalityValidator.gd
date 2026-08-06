class_name AIPersonalityValidator
extends DefinitionValidator

var _personalities: Array[AIPersonalityDefinition] = []
var _file_path: String = ""


func initialize(personalities: Array[AIPersonalityDefinition], file_path: String) -> void:
	_personalities = personalities
	_file_path = file_path


func get_definition_type() -> String:
	return "AIPersonality"


func validate(context: ValidationContext) -> Array[ContentDiagnostic]:
	var diagnostics: Array[ContentDiagnostic] = []
	var seen_ids: Dictionary = {}

	for personality in _personalities:
		_validate_personality(personality, context, seen_ids, diagnostics)

	return diagnostics


func _validate_personality(
	personality: AIPersonalityDefinition,
	context: ValidationContext,
	seen_ids: Dictionary,
	diagnostics: Array[ContentDiagnostic]
) -> void:
	if personality.id == "":
		diagnostics.append(ContentDiagnostic.create_error(
			"(unknown)", "AIPersonality", "Personality has empty id", _file_path, -1,
			"Add a unique id to the personality definition"
		))
		return

	if seen_ids.has(personality.id):
		diagnostics.append(ContentDiagnostic.create_error(
			personality.id, "AIPersonality", "Duplicate personality id", _file_path, -1,
			"Remove the duplicate personality or change its id"
		))
		return

	seen_ids[personality.id] = true
	context.ai_personality_ids.append(personality.id)
	_validate_personality_fields(personality, context, diagnostics)


func _validate_personality_fields(
	personality: AIPersonalityDefinition,
	context: ValidationContext,
	diagnostics: Array[ContentDiagnostic]
) -> void:
	if personality.display_name == "":
		diagnostics.append(ContentDiagnostic.create_warning(
			personality.id, "AIPersonality", "Personality has empty display_name",
			_file_path, -1, "Add a display name to the personality"
		))

	if personality.risk_tolerance < 0.0 or personality.risk_tolerance > 1.0:
		diagnostics.append(ContentDiagnostic.create_error(
			personality.id, "AIPersonality",
			"risk_tolerance out of range [0,1]: %.2f" % personality.risk_tolerance,
			_file_path, -1, "Set risk_tolerance between 0.0 and 1.0"
		))

	for affinity_id in personality.preferred_affinities:
		context.ai_personality_affinity_refs[personality.id] = affinity_id
