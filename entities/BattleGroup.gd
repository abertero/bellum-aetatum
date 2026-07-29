class_name BattleGroup
extends RefCounted

var frontline_position: Vector2 = Vector2.ZERO
var allied_team: String = ""
var enemy_team: String = ""
var allied_units: Array[UnitInstance] = []
var enemy_units: Array[UnitInstance] = []


func _init(position: Vector2) -> void:
	frontline_position = position


func add_allied_unit(unit: UnitInstance) -> void:
	if unit not in allied_units:
		allied_units.append(unit)


func add_enemy_unit(unit: UnitInstance) -> void:
	if unit not in enemy_units:
		enemy_units.append(unit)


func has_allied_unit(unit: UnitInstance) -> bool:
	return unit in allied_units


func has_enemy_unit(unit: UnitInstance) -> bool:
	return unit in enemy_units


func get_allied_count() -> int:
	return allied_units.size()


func get_enemy_count() -> int:
	return enemy_units.size()


func remove_unit(unit: UnitInstance) -> void:
	allied_units.erase(unit)
	enemy_units.erase(unit)


func get_frontline_allied() -> UnitInstance:
	for unit in allied_units:
		if is_instance_valid(unit) and unit.is_alive():
			return unit
	return null


func get_frontline_enemy() -> UnitInstance:
	for unit in enemy_units:
		if is_instance_valid(unit) and unit.is_alive():
			return unit
	return null


func has_frontline_melee_allied() -> bool:
	var frontline: UnitInstance = get_frontline_allied()
	return frontline != null and frontline.is_melee()


func has_frontline_melee_enemy() -> bool:
	var frontline: UnitInstance = get_frontline_enemy()
	return frontline != null and frontline.is_melee()


func cleanup() -> void:
	var valid_allied: Array[UnitInstance] = []
	for unit in allied_units:
		if is_instance_valid(unit) and unit.is_alive():
			valid_allied.append(unit)
	allied_units = valid_allied

	var valid_enemy: Array[UnitInstance] = []
	for unit in enemy_units:
		if is_instance_valid(unit) and unit.is_alive():
			valid_enemy.append(unit)
	enemy_units = valid_enemy
