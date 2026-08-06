class_name AbilityCommand
extends GameCommand

var ability_id: String = ""
var caster: UnitInstance = null
var target: Variant = null


static func create(
	p_ability_id: String,
	p_caster: UnitInstance,
	p_target: Variant = null,
	p_metadata: Dictionary = {}
) -> AbilityCommand:
	var cmd := AbilityCommand.new(p_metadata)
	cmd.ability_id = p_ability_id
	cmd.caster = p_caster
	cmd.target = p_target
	return cmd
