class_name StageDefinition
extends RefCounted

var battlefield_width: int = 0
var player_spawn_position: Vector2 = Vector2.ZERO
var enemy_spawn_position: Vector2 = Vector2.ZERO
var formation_spacing: float = 32.0
var background: String = ""


static func from_dictionary(data: Dictionary) -> StageDefinition:
	var definition := StageDefinition.new()
	definition.battlefield_width = int(data.get("battlefield_width", 0))
	var psp: Dictionary = data.get("player_spawn_position", {})
	definition.player_spawn_position = Vector2(float(psp.get("x", 0)), float(psp.get("y", 0)))
	var esp: Dictionary = data.get("enemy_spawn_position", {})
	definition.enemy_spawn_position = Vector2(float(esp.get("x", 0)), float(esp.get("y", 0)))
	definition.formation_spacing = float(data.get("formation_spacing", 32.0))
	definition.background = str(data.get("background", ""))
	return definition


static func create_fallback() -> StageDefinition:
	var definition := StageDefinition.new()
	definition.battlefield_width = 1152
	definition.player_spawn_position = Vector2(180, 280)
	definition.enemy_spawn_position = Vector2(972, 280)
	definition.formation_spacing = 32.0
	definition.background = ""
	return definition
