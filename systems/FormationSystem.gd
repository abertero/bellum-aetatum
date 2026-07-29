class_name FormationSystem
extends Node

const COLLISION_DISTANCE: float = 40.0

var _battle_groups: Array[BattleGroup] = []
var _formation_spacing: float = 32.0
var _all_units: Array[UnitInstance] = []


func initialize(formation_spacing: float) -> void:
	_formation_spacing = formation_spacing


func _ready() -> void:
	EventBus.unit_spawned.connect(_on_unit_spawned)


func _on_unit_spawned(unit: UnitInstance) -> void:
	register_unit(unit)


func get_battle_groups() -> Array[BattleGroup]:
	return _battle_groups


func register_unit(unit: UnitInstance) -> void:
	if unit not in _all_units:
		_all_units.append(unit)


func _physics_process(_delta: float) -> void:
	_cleanup_invalid_units()
	_detect_collisions()
	_update_formations()


func _cleanup_invalid_units() -> void:
	var valid_units: Array[UnitInstance] = []
	for unit in _all_units:
		if is_instance_valid(unit) and unit.is_alive():
			valid_units.append(unit)
	_all_units = valid_units


func _detect_collisions() -> void:
	for i in range(_all_units.size()):
		var unit_a: UnitInstance = _all_units[i]
		if not is_instance_valid(unit_a) or unit_a.current_state != UnitState.State.MOVING:
			continue

		for j in range(i + 1, _all_units.size()):
			var unit_b: UnitInstance = _all_units[j]
			if not is_instance_valid(unit_b) or unit_b.current_state != UnitState.State.MOVING:
				continue

			if _are_opposing(unit_a, unit_b):
				var distance: float = unit_a.position.distance_to(unit_b.position)
				if distance < COLLISION_DISTANCE:
					_create_or_join_battle_group(unit_a, unit_b)


func _are_opposing(unit_a: UnitInstance, unit_b: UnitInstance) -> bool:
	return unit_a.unit_owner != unit_b.unit_owner


func _create_or_join_battle_group(unit_a: UnitInstance, unit_b: UnitInstance) -> void:
	var group: BattleGroup = _find_existing_group(unit_a, unit_b)

	if group == null:
		var midpoint: Vector2 = (unit_a.position + unit_b.position) / 2.0
		group = BattleGroup.new(midpoint)
		_battle_groups.append(group)
		EventBus.frontline_changed.emit(group)

	_add_units_to_group(unit_a, unit_b, group)


func _find_existing_group(unit_a: UnitInstance, unit_b: UnitInstance) -> BattleGroup:
	for group in _battle_groups:
		if group.has_allied_unit(unit_a) or group.has_enemy_unit(unit_a):
			return group
		if group.has_allied_unit(unit_b) or group.has_enemy_unit(unit_b):
			return group
	return null


func _add_units_to_group(unit_a: UnitInstance, unit_b: UnitInstance, group: BattleGroup) -> void:
	if unit_a.unit_owner == "player":
		group.allied_team = "player"
		group.enemy_team = "enemy"
		group.add_allied_unit(unit_a)
		group.add_enemy_unit(unit_b)
	else:
		group.allied_team = "enemy"
		group.enemy_team = "player"
		group.add_allied_unit(unit_b)
		group.add_enemy_unit(unit_a)

	unit_a.set_battle_group(group)
	unit_b.set_battle_group(group)

	_position_unit_in_formation(unit_a, group)
	_position_unit_in_formation(unit_b, group)


func _update_formations() -> void:
	for group in _battle_groups:
		for unit in group.allied_units:
			if is_instance_valid(unit) and unit.current_state == UnitState.State.MOVING:
				_position_unit_in_formation(unit, group)

		for unit in group.enemy_units:
			if is_instance_valid(unit) and unit.current_state == UnitState.State.MOVING:
				_position_unit_in_formation(unit, group)


func _position_unit_in_formation(unit: UnitInstance, group: BattleGroup) -> void:
	var index: int = 0
	var is_allied: bool = group.has_allied_unit(unit)
	var units_array: Array[UnitInstance] = group.allied_units if is_allied else group.enemy_units

	for i in range(units_array.size()):
		if units_array[i] == unit:
			index = i
			break

	var offset: float = index * _formation_spacing
	var direction_multiplier: float = 1.0 if is_allied else -1.0

	var target_position: Vector2 = group.frontline_position
	target_position.x += direction_multiplier * offset

	unit.set_formation_target(target_position)
