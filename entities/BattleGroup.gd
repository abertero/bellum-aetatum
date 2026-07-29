class_name BattleGroup
extends RefCounted

var frontline_position: Vector2 = Vector2.ZERO
var player_formation: Array[UnitInstance] = []
var enemy_formation: Array[UnitInstance] = []


func _init(position: Vector2) -> void:
	frontline_position = position


func add_player_unit(unit: UnitInstance) -> void:
	if unit not in player_formation:
		player_formation.append(unit)


func add_enemy_unit(unit: UnitInstance) -> void:
	if unit not in enemy_formation:
		enemy_formation.append(unit)


func has_player_unit(unit: UnitInstance) -> bool:
	return unit in player_formation


func has_enemy_unit(unit: UnitInstance) -> bool:
	return unit in enemy_formation


func remove_unit(unit: UnitInstance) -> void:
	player_formation.erase(unit)
	enemy_formation.erase(unit)


func get_frontline(team: String) -> UnitInstance:
	var formation: Array[UnitInstance] = _get_formation(team)
	for unit in formation:
		if is_instance_valid(unit) and unit.is_alive():
			return unit
	return null


func get_next_target(for_unit: UnitInstance) -> UnitInstance:
	if has_player_unit(for_unit):
		return get_frontline("enemy")
	if has_enemy_unit(for_unit):
		return get_frontline("player")
	return null


func get_all_units() -> Array[UnitInstance]:
	var units: Array[UnitInstance] = []
	for unit in player_formation:
		if is_instance_valid(unit):
			units.append(unit)
	for unit in enemy_formation:
		if is_instance_valid(unit):
			units.append(unit)
	return units


func cleanup() -> void:
	player_formation = _filter_valid(player_formation)
	enemy_formation = _filter_valid(enemy_formation)


func is_empty() -> bool:
	return player_formation.is_empty() and enemy_formation.is_empty()


func _get_formation(team: String) -> Array[UnitInstance]:
	if team == "player":
		return player_formation
	if team == "enemy":
		return enemy_formation
	return []


func _filter_valid(formation: Array[UnitInstance]) -> Array[UnitInstance]:
	var valid: Array[UnitInstance] = []
	for unit in formation:
		if is_instance_valid(unit) and unit.is_alive():
			valid.append(unit)
	return valid
