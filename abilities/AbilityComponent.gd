class_name AbilityComponent
extends RefCounted

var component_type: String = ""
var configuration: Dictionary = {}


func initialize(config: Dictionary) -> void:
	configuration = config.duplicate()


func execute(_caster: UnitInstance, _target: Variant, _context: Dictionary) -> Array[GameCommand]:
	return []
