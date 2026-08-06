class_name GameModeDefinition
extends RefCounted

var id: String = ""
var display_name: String = ""
var default_ai_personality_id: String = ""
var match_rules_path: String = ""
var stage_path: String = ""
var metadata: Dictionary = {}


static func from_dictionary(data: Dictionary) -> GameModeDefinition:
	var definition := GameModeDefinition.new()
	definition.id = str(data.get("id", ""))
	definition.display_name = str(data.get("display_name", ""))
	definition.default_ai_personality_id = str(data.get("default_ai_personality_id", ""))
	definition.match_rules_path = str(data.get("match_rules_path", ""))
	definition.stage_path = str(data.get("stage_path", ""))

	var meta_data: Variant = data.get("metadata", {})
	if meta_data is Dictionary:
		definition.metadata = meta_data.duplicate()

	return definition
