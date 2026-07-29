class_name SpawnSystem
extends RefCounted

var _unit_factory: UnitFactory


func _init(unit_scene: PackedScene) -> void:
	_unit_factory = UnitFactory.new(unit_scene)


func spawn_unit(card_definition: UnitDefinition, spawn_position: Vector2, target_position: Vector2, parent: Node, team: String = "player") -> UnitInstance:
	var unit: UnitInstance = _unit_factory.create_unit(card_definition, team, parent)
	unit.position = spawn_position
	unit.configure_movement(target_position)
	EventBus.unit_spawned.emit(unit)
	return unit
