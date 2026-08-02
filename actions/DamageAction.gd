class_name DamageAction
extends GameAction

var damage: int = 0
var critical: bool = false
var blocked: bool = false


static func create(p_damage: int, p_source: Node, p_target: Node, p_critical: bool = false, p_blocked: bool = false, p_metadata: Dictionary = {}) -> DamageAction:
	var action := DamageAction.new(p_source, p_target, p_metadata)
	action.damage = p_damage
	action.critical = p_critical
	action.blocked = p_blocked
	return action
