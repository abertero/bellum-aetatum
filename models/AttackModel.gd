class_name AttackModel
extends RefCounted


func execute(attacker: UnitInstance, target: UnitInstance) -> DamageAction:
	return DamageAction.new()
