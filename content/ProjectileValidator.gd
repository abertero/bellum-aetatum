class_name ProjectileValidator
extends DefinitionValidator

var _projectiles: Array[ProjectileDefinition] = []
var _file_path: String = ""


func initialize(projectiles: Array[ProjectileDefinition], file_path: String) -> void:
	_projectiles = projectiles
	_file_path = file_path


func get_definition_type() -> String:
	return "Projectile"


func validate(context: ValidationContext) -> Array[ContentDiagnostic]:
	var diagnostics: Array[ContentDiagnostic] = []
	var seen_ids: Dictionary = {}

	for projectile in _projectiles:
		_validate_projectile(projectile, context, seen_ids, diagnostics)

	return diagnostics


func _validate_projectile(
	projectile: ProjectileDefinition,
	context: ValidationContext,
	seen_ids: Dictionary,
	diagnostics: Array[ContentDiagnostic]
) -> void:
	if projectile.id == "":
		diagnostics.append(ContentDiagnostic.create_error(
			"(unknown)", "Projectile", "Projectile has empty id", _file_path, -1,
			"Add a unique id to the projectile definition"
		))
		return

	if seen_ids.has(projectile.id):
		diagnostics.append(ContentDiagnostic.create_error(
			projectile.id, "Projectile", "Duplicate projectile id", _file_path, -1,
			"Remove the duplicate projectile or change its id"
		))
		return

	seen_ids[projectile.id] = true
	context.projectile_ids.append(projectile.id)
	_validate_projectile_fields(projectile, diagnostics)


func _validate_projectile_fields(
	projectile: ProjectileDefinition,
	diagnostics: Array[ContentDiagnostic]
) -> void:
	if projectile.speed <= 0.0:
		diagnostics.append(ContentDiagnostic.create_error(
			projectile.id, "Projectile", "Projectile has invalid speed: %.1f" % projectile.speed,
			_file_path, -1, "Set speed to a positive value"
		))

	if projectile.max_range <= 0.0:
		diagnostics.append(ContentDiagnostic.create_error(
			projectile.id, "Projectile", "Projectile has invalid max_range: %.1f" % projectile.max_range,
			_file_path, -1, "Set max_range to a positive value"
		))

	if projectile.damage < 0:
		diagnostics.append(ContentDiagnostic.create_error(
			projectile.id, "Projectile", "Projectile has negative damage: %d" % projectile.damage,
			_file_path, -1, "Set damage to a non-negative value"
		))

	if projectile.image != "" and not ResourceLoader.exists(projectile.image):
		diagnostics.append(ContentDiagnostic.create_warning(
			projectile.id, "Projectile", "Projectile image not found: %s" % projectile.image,
			_file_path, -1, "Add the image file or remove the image reference"
		))
