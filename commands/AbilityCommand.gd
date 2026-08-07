class_name AbilityCommand
extends GameCommand

var ability_id: String = ""
var caster_id: String = ""
var caster: UnitInstance = null
var target: Variant = null


static func create(
	p_ability_id: String,
	p_caster: UnitInstance,
	p_target: Variant = null,
	p_metadata: Dictionary = {}
) -> AbilityCommand:
	var cmd := AbilityCommand.new()
	cmd.ability_id = p_ability_id
	cmd.caster = p_caster
	cmd.caster_id = _get_unit_id(p_caster)
	cmd.target = p_target
	cmd.metadata = p_metadata.duplicate()
	return cmd


func get_command_type() -> String:
	return "AbilityCommand"


func serialize() -> Dictionary:
	var data: Dictionary = super.serialize()
	data["ability_id"] = ability_id
	data["caster_id"] = caster_id
	return data


func deserialize(data: Dictionary) -> void:
	super.deserialize(data)
	ability_id = str(data.get("ability_id", ""))
	caster_id = str(data.get("caster_id", ""))


static func _get_unit_id(unit: UnitInstance) -> String:
	if unit == null or not is_instance_valid(unit):
		return ""
	return unit.entity_id
