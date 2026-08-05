class_name SpawnProjectileComponent
extends AbilityComponent


func execute(caster: UnitInstance, _target: Variant, context: Dictionary) -> Array[GameCommand]:
	var projectile_id: String = configuration.get("projectile_id", "")
	if projectile_id == "":
		return []

	var target_unit: UnitInstance = _resolve_target(caster)
	if target_unit == null or not is_instance_valid(target_unit):
		return []

	var registry: ProjectileDefinitionRegistry = context.get("projectile_registry")
	if registry == null:
		return []

	var parent_node: Node = context.get("parent_node")
	if parent_node == null:
		return []

	var projectile_def: ProjectileDefinition = registry.resolve(projectile_id)
	if projectile_def == null:
		return []

	ProjectileFactory.create_projectile(projectile_def, caster, target_unit, parent_node)
	return []


func _resolve_target(caster: UnitInstance) -> UnitInstance:
	if caster == null or not is_instance_valid(caster):
		return null
	return caster.get_current_target()
