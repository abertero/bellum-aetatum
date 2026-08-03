class_name ProjectileDefinitionRegistry
extends RefCounted

var _definitions: Dictionary = {}


func register(definition_id: String, definition: ProjectileDefinition) -> void:
	_definitions[definition_id] = definition


func resolve(definition_id: String) -> ProjectileDefinition:
	if not _definitions.has(definition_id):
		return null
	return _definitions[definition_id]


func get_all_ids() -> Array:
	return _definitions.keys()
