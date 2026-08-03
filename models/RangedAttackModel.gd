class_name RangedAttackModel
extends AttackModel

var _projectile_registry: ProjectileDefinitionRegistry
var _parent_node: Node


func initialize(projectile_registry: ProjectileDefinitionRegistry, parent_node: Node) -> void:
	_projectile_registry = projectile_registry
	_parent_node = parent_node


func execute(attacker: UnitInstance, target: UnitInstance) -> DamageAction:
	var projectile_id: String = attacker.definition.projectile_id
	var projectile_def: ProjectileDefinition = _projectile_registry.resolve(projectile_id)
	
	if projectile_def == null:
		return DamageAction.create(0, attacker, target)
	
	ProjectileFactory.create_projectile(projectile_def, attacker, target, _parent_node)
	
	return DamageAction.create(0, attacker, target)
