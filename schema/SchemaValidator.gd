class_name SchemaValidator
extends RefCounted

var _current_version: SchemaVersion = null


func initialize(current_version: SchemaVersion) -> void:
	_current_version = current_version


func validate(data: Dictionary, file_path: String) -> Array[ContentDiagnostic]:
	var diagnostics: Array[ContentDiagnostic] = []
	if not data.has("schema_version"):
		var diag := ContentDiagnostic.create_error(
			"schema",
			"schema_version",
			"File is missing required 'schema_version' field",
			file_path
		)
		diagnostics.append(diag)
		return diagnostics

	var file_version: SchemaVersion = _parse_version(data["schema_version"])
	if file_version == null:
		var diag := ContentDiagnostic.create_error(
			"schema",
			"schema_version",
			"File has invalid 'schema_version' format",
			file_path
		)
		diagnostics.append(diag)
		return diagnostics

	if not file_version.is_compatible(_current_version):
		var diag := ContentDiagnostic.create_error(
			"schema",
			"schema_version",
			"File schema %s is incompatible with engine schema %s" % [file_version.to_version_string(), _current_version.to_version_string()],
			file_path
		)
		diagnostics.append(diag)

	return diagnostics


func _parse_version(version_data: Variant) -> SchemaVersion:
	if version_data is String:
		return SchemaVersion.from_string(version_data)
	if version_data is Dictionary:
		return SchemaVersion.from_dictionary(version_data)
	return null
