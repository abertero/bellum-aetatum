class_name ContentMigrationRegistry
extends RefCounted

var _migrations: Dictionary = {}


func register_migration(from_version: SchemaVersion, to_version: SchemaVersion, migration_func: Callable) -> void:
	var key: String = from_version.to_version_string()
	if not _migrations.has(key):
		_migrations[key] = []
	var entry: Dictionary = {"to": to_version, "func": migration_func}
	_migrations[key].append(entry)


func get_migration_path(from_version: SchemaVersion, to_version: SchemaVersion) -> Array[Dictionary]:
	var path: Array[Dictionary] = []
	var current: SchemaVersion = from_version
	while not current.equals(to_version):
		var key: String = current.to_version_string()
		if not _migrations.has(key):
			return []
		var found: bool = false
		for entry in _migrations[key]:
			var next_version: SchemaVersion = entry["to"]
			if next_version.is_compatible(to_version) or next_version.equals(to_version):
				path.append(entry)
				current = next_version
				found = true
				break
		if not found:
			return []
	return path


func has_migrations() -> bool:
	return not _migrations.is_empty()
