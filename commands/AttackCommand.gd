class_name AttackCommand
extends GameCommand

var attacker: UnitInstance
var target: UnitInstance


static func create(p_attacker: UnitInstance, p_target: UnitInstance, p_metadata: Dictionary = {}) -> AttackCommand:
	var cmd := AttackCommand.new(p_metadata)
	cmd.attacker = p_attacker
	cmd.target = p_target
	return cmd
