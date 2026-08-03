class_name ProjectileSystem
extends Node

var _simulation_context: SimulationContext
var _active_projectiles: Array[ProjectileInstance] = []


func initialize(simulation_context: SimulationContext) -> void:
	_simulation_context = simulation_context
	EventBus.projectile_spawned.connect(_on_projectile_spawned)


func _physics_process(_delta: float) -> void:
	_update_all_projectiles()
	_cleanup_expired_projectiles()


func _update_all_projectiles() -> void:
	var delta: float = _simulation_context.delta_time
	for projectile in _active_projectiles:
		if is_instance_valid(projectile):
			projectile.update_movement(delta)
			EventBus.projectile_moved.emit(projectile)


func _cleanup_expired_projectiles() -> void:
	var valid_projectiles: Array[ProjectileInstance] = []
	for projectile in _active_projectiles:
		if is_instance_valid(projectile) and not projectile.is_expired():
			valid_projectiles.append(projectile)
		elif is_instance_valid(projectile):
			EventBus.projectile_destroyed.emit(projectile)
			projectile.queue_free()
	_active_projectiles = valid_projectiles


func _on_projectile_spawned(projectile: ProjectileInstance) -> void:
	if projectile not in _active_projectiles:
		_active_projectiles.append(projectile)


func get_active_projectiles() -> Array[ProjectileInstance]:
	return _active_projectiles.duplicate()


func get_projectile_count() -> int:
	return _active_projectiles.size()
