class_name EffectValidator
extends DefinitionValidator

var _effects: Array[EffectDefinition] = []
var _file_path: String = ""


func initialize(effects: Array[EffectDefinition], file_path: String) -> void:
	_effects = effects
	_file_path = file_path


func get_definition_type() -> String:
	return "Effect"


func validate(context: ValidationContext) -> Array[ContentDiagnostic]:
	var diagnostics: Array[ContentDiagnostic] = []
	var seen_ids: Dictionary = {}

	for effect in _effects:
		_validate_effect(effect, context, seen_ids, diagnostics)

	return diagnostics


func _validate_effect(
	effect: EffectDefinition,
	context: ValidationContext,
	seen_ids: Dictionary,
	diagnostics: Array[ContentDiagnostic]
) -> void:
	if effect.id == "":
		diagnostics.append(ContentDiagnostic.create_error(
			"(unknown)", "Effect", "Effect has empty id", _file_path, -1,
			"Add a unique id to the effect definition"
		))
		return

	if seen_ids.has(effect.id):
		diagnostics.append(ContentDiagnostic.create_error(
			effect.id, "Effect", "Duplicate effect id", _file_path, -1,
			"Remove the duplicate effect or change its id"
		))
		return

	seen_ids[effect.id] = true
	context.effect_ids.append(effect.id)

	if effect.display_name == "":
		diagnostics.append(ContentDiagnostic.create_warning(
			effect.id, "Effect", "Effect has empty display_name", _file_path, -1,
			"Add a display name to the effect"
		))

	if effect.icon != "" and not ResourceLoader.exists(effect.icon):
		diagnostics.append(ContentDiagnostic.create_warning(
			effect.id, "Effect", "Effect icon not found: %s" % effect.icon, _file_path, -1,
			"Add the icon file or remove the icon reference"
		))
