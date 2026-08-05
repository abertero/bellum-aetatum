class_name AbilityInstance
extends RefCounted

var instance_id: String = ""
var definition: AbilityDefinition = null
var owner: Variant = null
var runtime_state: Dictionary = {}
var metadata: Dictionary = {}
var executed_components: Array[String] = []
var generated_commands: Array[GameCommand] = []

static var _next_id: int = 0


static func create(p_definition: AbilityDefinition, p_owner: Variant) -> AbilityInstance:
	var instance := AbilityInstance.new()
	AbilityInstance._next_id += 1
	instance.instance_id = "ability_%d" % AbilityInstance._next_id
	instance.definition = p_definition
	instance.owner = p_owner
	instance.runtime_state = {}
	instance.metadata = p_definition.metadata.duplicate()
	return instance


func record_component(component_type: String) -> void:
	executed_components.append(component_type)


func record_command(command: GameCommand) -> void:
	generated_commands.append(command)


func get_component_count() -> int:
	return executed_components.size()


func get_command_count() -> int:
	return generated_commands.size()
