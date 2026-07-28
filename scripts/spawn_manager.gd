class_name SpawnManager
extends RefCounted

var _unit_scene: PackedScene


func _init(unit_scene: PackedScene) -> void:
	_unit_scene = unit_scene


func spawn_unit(card_data: Dictionary, spawn_position: Vector2, target_position: Vector2, parent: Node, team: String = "player") -> Unit:
	var unit: Unit = _unit_scene.instantiate()
	parent.add_child(unit)
	unit.position = spawn_position
	unit.initialize(card_data, team)
	unit.configure_movement(target_position)
	EventBus.unit_spawned.emit(unit)
	return unit
