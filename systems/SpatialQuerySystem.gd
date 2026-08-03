class_name SpatialQuerySystem
extends RefCounted

var _formation_system: FormationSystem


func initialize(formation_system: FormationSystem) -> void:
	_formation_system = formation_system


func get_frontline(for_unit: UnitInstance) -> UnitInstance:
	var group: BattleGroup = for_unit.battle_group
	if group == null:
		return null
	if group.has_player_unit(for_unit):
		return group.get_frontline("enemy")
	if group.has_enemy_unit(for_unit):
		return group.get_frontline("player")
	return null


func get_units_in_formation(owner: String) -> Array[UnitInstance]:
	var result: Array[UnitInstance] = []
	for group in _formation_system.get_battle_groups():
		var formation: Array[UnitInstance] = _get_formation_by_owner(group, owner)
		for unit in formation:
			if is_instance_valid(unit) and unit.is_alive():
				result.append(unit)
	return result


func get_units_by_owner(owner: String) -> Array[UnitInstance]:
	var result: Array[UnitInstance] = []
	for unit in _formation_system.get_all_units():
		if is_instance_valid(unit) and unit.is_alive() and unit.unit_owner == owner:
			result.append(unit)
	return result


func get_units_by_state(state: int) -> Array[UnitInstance]:
	var result: Array[UnitInstance] = []
	for unit in _formation_system.get_all_units():
		if is_instance_valid(unit) and unit.is_alive() and unit.current_state == state:
			result.append(unit)
	return result


func get_closest_enemy(unit: UnitInstance) -> UnitInstance:
	var enemy_owner: String = "enemy" if unit.unit_owner == "player" else "player"
	var closest: UnitInstance = null
	var closest_distance: float = INF
	for enemy in get_units_by_owner(enemy_owner):
		var distance: float = unit.position.distance_to(enemy.position)
		if distance < closest_distance:
			closest_distance = distance
			closest = enemy
	return closest


func get_battle_group_count() -> int:
	return _formation_system.get_battle_groups().size()


func get_units_in_group(group_index: int) -> Array[UnitInstance]:
	var groups: Array[BattleGroup] = _formation_system.get_battle_groups()
	if group_index < 0 or group_index >= groups.size():
		return []
	return groups[group_index].get_all_units()


func get_group_frontline(group_index: int, team: String) -> UnitInstance:
	var groups: Array[BattleGroup] = _formation_system.get_battle_groups()
	if group_index < 0 or group_index >= groups.size():
		return null
	return groups[group_index].get_frontline(team)


func _get_formation_by_owner(group: BattleGroup, owner: String) -> Array[UnitInstance]:
	if owner == "player":
		return group.player_formation
	if owner == "enemy":
		return group.enemy_formation
	return []


func get_projectile_collisions(projectile: ProjectileInstance) -> Array[UnitInstance]:
	var result: Array[UnitInstance] = []
	var collision_radius: float = 8.0
	var enemy_owner: String = "enemy" if projectile.owner_unit.unit_owner == "player" else "player"
	
	for unit in get_units_by_owner(enemy_owner):
		if not is_instance_valid(unit) or not unit.is_alive():
			continue
		var distance: float = projectile.position.distance_to(unit.position)
		if distance <= collision_radius:
			result.append(unit)
	
	return result


func get_units_along_path(start: Vector2, end: Vector2, width: float = 8.0) -> Array[UnitInstance]:
	var result: Array[UnitInstance] = []
	var path_direction: Vector2 = (end - start).normalized()
	var path_length: float = start.distance_to(end)
	
	for unit in _formation_system.get_all_units():
		if not is_instance_valid(unit) or not unit.is_alive():
			continue
		
		var to_unit: Vector2 = unit.position - start
		var projection: float = to_unit.dot(path_direction)
		
		if projection < 0 or projection > path_length:
			continue
		
		var closest_point: Vector2 = start + path_direction * projection
		var distance: float = unit.position.distance_to(closest_point)
		
		if distance <= width:
			result.append(unit)
	
	return result
