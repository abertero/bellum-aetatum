class_name ProjectileFactory
extends RefCounted

static var _counter: int = 0
static var debug_mode: bool = false


static func create_projectile(
	definition: ProjectileDefinition,
	owner: UnitInstance,
	target: UnitInstance,
	parent: Node
) -> ProjectileInstance:
	_counter += 1
	var projectile_id: String = "projectile_%s_%d" % [definition.id, _counter]
	
	var spawn_position: Vector2 = owner.position
	var direction: Vector2 = (target.position - owner.position).normalized()
	
	var projectile := ProjectileInstance.new()
	projectile.name = projectile_id
	projectile.debug_mode = debug_mode
	parent.add_child(projectile)
	
	projectile.initialize(
		projectile_id,
		spawn_position,
		direction,
		definition.speed,
		owner,
		target,
		definition.max_range,
		definition.projectile_type,
		definition.image,
		{"damage": definition.damage}
	)
	
	EventBus.projectile_spawned.emit(projectile)
	return projectile
