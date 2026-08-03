class_name CombatModifier
extends RefCounted

enum Operation {
	MULTIPLY,
	ADD,
	OVERRIDE,
	MIN,
	MAX
}

var id: String = ""
var source: String = ""
var priority: int = 0
var operation: Operation = Operation.MULTIPLY
var value: float = 1.0
var description: String = ""
var metadata: Dictionary = {}


static func create_multiply(p_id: String, p_source: String, p_value: float, p_priority: int = 0, p_description: String = "", p_metadata: Dictionary = {}) -> CombatModifier:
	var modifier := CombatModifier.new()
	modifier.id = p_id
	modifier.source = p_source
	modifier.priority = p_priority
	modifier.operation = Operation.MULTIPLY
	modifier.value = p_value
	modifier.description = p_description
	modifier.metadata = p_metadata.duplicate()
	return modifier


static func create_add(p_id: String, p_source: String, p_value: float, p_priority: int = 0, p_description: String = "", p_metadata: Dictionary = {}) -> CombatModifier:
	var modifier := CombatModifier.new()
	modifier.id = p_id
	modifier.source = p_source
	modifier.priority = p_priority
	modifier.operation = Operation.ADD
	modifier.value = p_value
	modifier.description = p_description
	modifier.metadata = p_metadata.duplicate()
	return modifier


static func create_override(p_id: String, p_source: String, p_value: float, p_priority: int = 0, p_description: String = "", p_metadata: Dictionary = {}) -> CombatModifier:
	var modifier := CombatModifier.new()
	modifier.id = p_id
	modifier.source = p_source
	modifier.priority = p_priority
	modifier.operation = Operation.OVERRIDE
	modifier.value = p_value
	modifier.description = p_description
	modifier.metadata = p_metadata.duplicate()
	return modifier


static func create_min(p_id: String, p_source: String, p_value: float, p_priority: int = 0, p_description: String = "", p_metadata: Dictionary = {}) -> CombatModifier:
	var modifier := CombatModifier.new()
	modifier.id = p_id
	modifier.source = p_source
	modifier.priority = p_priority
	modifier.operation = Operation.MIN
	modifier.value = p_value
	modifier.description = p_description
	modifier.metadata = p_metadata.duplicate()
	return modifier


static func create_max(p_id: String, p_source: String, p_value: float, p_priority: int = 0, p_description: String = "", p_metadata: Dictionary = {}) -> CombatModifier:
	var modifier := CombatModifier.new()
	modifier.id = p_id
	modifier.source = p_source
	modifier.priority = p_priority
	modifier.operation = Operation.MAX
	modifier.value = p_value
	modifier.description = p_description
	modifier.metadata = p_metadata.duplicate()
	return modifier


func get_operation_name() -> String:
	match operation:
		Operation.MULTIPLY:
			return "MULTIPLY"
		Operation.ADD:
			return "ADD"
		Operation.OVERRIDE:
			return "OVERRIDE"
		Operation.MIN:
			return "MIN"
		Operation.MAX:
			return "MAX"
		_:
			return "UNKNOWN"
