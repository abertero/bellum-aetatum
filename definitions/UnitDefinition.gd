class_name UnitDefinition
extends RefCounted

var id: String = ""
var name: String = ""
var image: String = ""
var hp: int = 0
var attack: int = 0
var range: int = 0
var speed: float = 0.0
var cost: int = 0
var attack_speed: float = 1.0


static func from_dictionary(data: Dictionary) -> UnitDefinition:
	var definition := UnitDefinition.new()
	definition.id = str(data.get("id", ""))
	definition.name = str(data.get("name", ""))
	definition.image = str(data.get("image", ""))
	var stats_data: Dictionary = data.get("stats", {})
	definition.hp = int(stats_data.get("hp", 0))
	definition.attack = int(stats_data.get("attack", 0))
	definition.range = int(stats_data.get("range", 0))
	definition.speed = float(stats_data.get("speed", 0.0))
	definition.cost = int(stats_data.get("cost", 0))
	definition.attack_speed = float(stats_data.get("attack_speed", 1.0))
	return definition
