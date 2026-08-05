class_name MatchCondition
extends RefCounted

var condition_type: String = ""
var configuration: Dictionary = {}


func initialize(config: Dictionary) -> void:
	configuration = config.duplicate()


func check(_context: Dictionary) -> bool:
	return false


func get_description() -> String:
	return condition_type
