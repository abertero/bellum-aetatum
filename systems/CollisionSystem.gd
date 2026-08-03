class_name CollisionSystem
extends Node

var _projectile_system: ProjectileSystem


func initialize(projectile_system: ProjectileSystem) -> void:
	_projectile_system = projectile_system


func _physics_process(_delta: float) -> void:
	_check_projectile_collisions()


func _check_projectile_collisions() -> void:
	var projectiles: Array[ProjectileInstance] = _projectile_system.get_active_projectiles()
	for projectile in projectiles:
		if not is_instance_valid(projectile):
			continue
		if projectile.has_reached_target():
			_handle_projectile_collision(projectile)


func _handle_projectile_collision(projectile: ProjectileInstance) -> void:
	var target: UnitInstance = projectile.target_unit
	if target == null or not is_instance_valid(target):
		EventBus.projectile_destroyed.emit(projectile)
		projectile.queue_free()
		return
	
	if not target.is_alive():
		EventBus.projectile_destroyed.emit(projectile)
		projectile.queue_free()
		return
	
	var damage: int = projectile.get_metadata("damage", 0)
	if damage <= 0:
		EventBus.projectile_destroyed.emit(projectile)
		projectile.queue_free()
		return
	
	EventBus.projectile_collided.emit(projectile, target)
	
	var action: DamageAction = DamageAction.create(
		damage,
		projectile.owner_unit,
		target,
		false,
		false,
		{"projectile_id": projectile.id, "projectile_type": projectile.projectile_type}
	)
	
	EventBus.action_performed.emit(action)
	
	EventBus.projectile_destroyed.emit(projectile)
	projectile.queue_free()
