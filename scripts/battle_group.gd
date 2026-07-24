class_name BattleGroup
extends RefCounted

var frontline_position: Vector2 = Vector2.ZERO
var allied_units: Array[Unit] = []
var enemy_units: Array[Unit] = []


func _init(position: Vector2) -> void:
	frontline_position = position


func add_allied_unit(unit: Unit) -> void:
	if unit not in allied_units:
		allied_units.append(unit)


func add_enemy_unit(unit: Unit) -> void:
	if unit not in enemy_units:
		enemy_units.append(unit)


func has_allied_unit(unit: Unit) -> bool:
	return unit in allied_units


func has_enemy_unit(unit: Unit) -> bool:
	return unit in enemy_units


func get_allied_count() -> int:
	return allied_units.size()


func get_enemy_count() -> int:
	return enemy_units.size()
