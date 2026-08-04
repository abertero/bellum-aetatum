class_name EffectDefinition
extends RefCounted

var id: String = ""
var display_name: String = ""
var description: String = ""
var icon: String = ""
var duration: float = 0.0
var stacking_policy: String = "NO_STACK"
var refresh_policy: String = "REFRESH_DURATION"
var visual_hint: String = ""
var triggers: Array[String] = []
var modifiers: Array[Dictionary] = []
var metadata: Dictionary = {}


static func from_dictionary(data: Dictionary) -> EffectDefinition:
	var definition := EffectDefinition.new()
	definition.id = str(data.get("id", ""))
	definition.display_name = str(data.get("display_name", ""))
	definition.description = str(data.get("description", ""))
	definition.icon = str(data.get("icon", ""))
	definition.duration = float(data.get("duration", 0.0))
	definition.stacking_policy = str(data.get("stacking_policy", "NO_STACK"))
	definition.refresh_policy = str(data.get("refresh_policy", "REFRESH_DURATION"))
	definition.visual_hint = str(data.get("visual_hint", ""))

	var triggers_data: Variant = data.get("triggers", [])
	if triggers_data is Array:
		for trigger in triggers_data:
			definition.triggers.append(str(trigger))

	var modifiers_data: Variant = data.get("modifiers", [])
	if modifiers_data is Array:
		for modifier in modifiers_data:
			if modifier is Dictionary:
				definition.modifiers.append(modifier.duplicate())

	var metadata_data: Variant = data.get("metadata", {})
	if metadata_data is Dictionary:
		definition.metadata = metadata_data.duplicate()

	return definition
