class_name ProjectileDefinition
extends RefCounted

var id: String = ""
var display_name: String = ""
var speed: float = 0.0
var max_range: float = 0.0
var damage: int = 0
var projectile_type: String = ""
var image: String = ""


static func from_dictionary(data: Dictionary) -> ProjectileDefinition:
	var definition := ProjectileDefinition.new()
	definition.id = str(data.get("id", ""))
	definition.display_name = str(data.get("display_name", ""))
	definition.speed = float(data.get("speed", 0.0))
	definition.max_range = float(data.get("max_range", 0.0))
	definition.damage = int(data.get("damage", 0))
	definition.projectile_type = str(data.get("projectile_type", ""))
	definition.image = str(data.get("image", ""))
	return definition
