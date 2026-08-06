class_name AffinityValidator
extends DefinitionValidator

var _affinities: Array[AffinityDefinition] = []
var _file_path: String = ""


func initialize(affinities: Array[AffinityDefinition], file_path: String) -> void:
	_affinities = affinities
	_file_path = file_path


func get_definition_type() -> String:
	return "Affinity"


func validate(context: ValidationContext) -> Array[ContentDiagnostic]:
	var diagnostics: Array[ContentDiagnostic] = []
	var seen_ids: Dictionary = {}

	for affinity in _affinities:
		_validate_affinity(affinity, context, seen_ids, diagnostics)

	return diagnostics


func _validate_affinity(
	affinity: AffinityDefinition,
	context: ValidationContext,
	seen_ids: Dictionary,
	diagnostics: Array[ContentDiagnostic]
) -> void:
	if affinity.id == "":
		diagnostics.append(ContentDiagnostic.create_error(
			"(unknown)", "Affinity", "Affinity has empty id", _file_path, -1,
			"Add a unique id to the affinity definition"
		))
		return

	if seen_ids.has(affinity.id):
		diagnostics.append(ContentDiagnostic.create_error(
			affinity.id, "Affinity", "Duplicate affinity id", _file_path, -1,
			"Remove the duplicate affinity or change its id"
		))
		return

	seen_ids[affinity.id] = true
	context.affinity_ids.append(affinity.id)

	if affinity.display_name == "":
		diagnostics.append(ContentDiagnostic.create_warning(
			affinity.id, "Affinity", "Affinity has empty display_name", _file_path, -1,
			"Add a display name to the affinity"
		))

	if affinity.icon != "" and not ResourceLoader.exists(affinity.icon):
		diagnostics.append(ContentDiagnostic.create_warning(
			affinity.id, "Affinity", "Affinity icon not found: %s" % affinity.icon, _file_path, -1,
			"Add the icon file or remove the icon reference"
		))
