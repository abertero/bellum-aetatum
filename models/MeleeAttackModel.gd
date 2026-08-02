class_name MeleeAttackModel
extends AttackModel


func execute(attacker: UnitInstance, target: UnitInstance) -> DamageAction:
	return DamageAction.create(attacker.definition.attack, attacker, target)
