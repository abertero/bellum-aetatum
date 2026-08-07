class_name SpawnSystem
extends RefCounted

var _unit_factory: UnitFactory
var _simulation_context: SimulationContext = null


func _init(unit_scene: PackedScene) -> void:
	_unit_factory = UnitFactory.new(unit_scene)


func set_simulation_context(p_context: SimulationContext) -> void:
	_simulation_context = p_context


func spawn_unit(card_definition: UnitDefinition, spawn_position: Vector2, target_position: Vector2, parent: Node, team: String = "player") -> UnitInstance:
	var unit: UnitInstance = _unit_factory.create_unit(card_definition, team, parent)
	_assign_entity_id(unit)
	unit.position = spawn_position
	unit.configure_movement(target_position)
	EventBus.unit_spawned.emit(unit)
	return unit


func _assign_entity_id(unit: UnitInstance) -> void:
	if _simulation_context != null:
		unit.entity_id = "unit_%d_%d" % [_simulation_context.tick, _simulation_context.next_entity_id()]
	else:
		unit.entity_id = "unit_%d" % unit.get_instance_id()
