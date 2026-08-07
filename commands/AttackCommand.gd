class_name AttackCommand
extends GameCommand

var attacker_id: String = ""
var target_id: String = ""
var attacker: UnitInstance = null
var target: UnitInstance = null


static func create(p_attacker: UnitInstance, p_target: UnitInstance, p_metadata: Dictionary = {}) -> AttackCommand:
	var cmd := AttackCommand.new()
	cmd.attacker = p_attacker
	cmd.target = p_target
	cmd.attacker_id = _get_unit_id(p_attacker)
	cmd.target_id = _get_unit_id(p_target)
	cmd.metadata = p_metadata.duplicate()
	return cmd


func get_command_type() -> String:
	return "AttackCommand"


func serialize() -> Dictionary:
	var data: Dictionary = super.serialize()
	data["attacker_id"] = attacker_id
	data["target_id"] = target_id
	return data


func deserialize(data: Dictionary) -> void:
	super.deserialize(data)
	attacker_id = str(data.get("attacker_id", ""))
	target_id = str(data.get("target_id", ""))


static func _get_unit_id(unit: UnitInstance) -> String:
	if unit == null or not is_instance_valid(unit):
		return ""
	return unit.entity_id
