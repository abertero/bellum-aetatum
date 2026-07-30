class_name MeleeAttackModel
extends AttackModel


func execute(attacker: UnitInstance, target: UnitInstance) -> DamageResult:
	var result := DamageResult.new()
	result.damage = attacker.definition.attack
	result.source = attacker
	result.target = target
	return result
