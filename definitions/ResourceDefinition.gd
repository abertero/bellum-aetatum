class_name ResourceDefinition
extends RefCounted

var id: String = ""
var display_name: String = ""
var maximum: int = 0
var starting_value: int = 0
var regeneration_rate: float = 0.0


static func from_dictionary(data: Dictionary) -> ResourceDefinition:
	var definition := ResourceDefinition.new()
	definition.id = str(data.get("id", ""))
	definition.display_name = str(data.get("display_name", ""))
	definition.maximum = int(data.get("maximum", 0))
	definition.starting_value = int(data.get("starting_value", 0))
	definition.regeneration_rate = float(data.get("regeneration_rate", 0.0))
	return definition
