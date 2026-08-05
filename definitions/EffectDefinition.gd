class_name EffectDefinition
extends RefCounted

var id: String = ""
var display_name: String = ""
var description: String = ""
var icon: String = ""
var stacking_policy: String = "NO_STACK"
var visual_hint: String = ""
var components: Array[Dictionary] = []
var metadata: Dictionary = {}


static func from_dictionary(data: Dictionary) -> EffectDefinition:
	var definition := EffectDefinition.new()
	definition.id = str(data.get("id", ""))
	definition.display_name = str(data.get("display_name", ""))
	definition.description = str(data.get("description", ""))
	definition.icon = str(data.get("icon", ""))
	definition.stacking_policy = str(data.get("stacking_policy", "NO_STACK"))
	definition.visual_hint = str(data.get("visual_hint", ""))

	var components_data: Variant = data.get("components", [])
	if components_data is Array:
		for component in components_data:
			if component is Dictionary:
				definition.components.append(component.duplicate())

	var metadata_data: Variant = data.get("metadata", {})
	if metadata_data is Dictionary:
		definition.metadata = metadata_data.duplicate()

	return definition
