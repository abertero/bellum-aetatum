class_name ProjectileLoader
extends RefCounted


static func load_projectiles(file_path: String) -> Array[ProjectileDefinition]:
	var result: Array[ProjectileDefinition] = []
	var data: Variant = JsonLoader.load_json(file_path)

	if data == null or not data is Dictionary:
		return result

	if not data.has("projectiles"):
		return result

	var projectiles_data: Variant = data["projectiles"]
	if not projectiles_data is Array:
		return result

	for projectile_data in projectiles_data:
		if projectile_data is Dictionary:
			var projectile: ProjectileDefinition = ProjectileDefinition.from_dictionary(projectile_data)
			result.append(projectile)

	return result
