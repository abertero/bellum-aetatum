class_name UnitFactory
extends RefCounted

var _unit_scene: PackedScene


func _init(unit_scene: PackedScene) -> void:
	_unit_scene = unit_scene


func create_unit(card_definition: UnitDefinition, p_owner: String, parent: Node) -> UnitInstance:
	var unit: UnitInstance = _unit_scene.instantiate()
	parent.add_child(unit)
	unit.initialize(card_definition, p_owner)
	return unit
