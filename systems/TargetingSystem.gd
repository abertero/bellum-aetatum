class_name TargetingSystem
extends Node

var _spatial_query: SpatialQuerySystem


func initialize(spatial_query: SpatialQuerySystem) -> void:
	_spatial_query = spatial_query


func _physics_process(_delta: float) -> void:
	_assign_targets_for_team("player")
	_assign_targets_for_team("enemy")


func _assign_targets_for_team(team: String) -> void:
	var formation: Array[UnitInstance] = _spatial_query.get_units_in_formation(team)
	for unit in formation:
		if not unit.is_melee():
			continue
		var target: UnitInstance = _spatial_query.get_frontline(unit)
		_assign_target(unit, target)


func _assign_target(unit: UnitInstance, target: UnitInstance) -> void:
	var old_target: UnitInstance = unit.get_current_target()
	if old_target != target:
		unit.current_target = target
		EventBus.target_changed.emit(unit, target)
