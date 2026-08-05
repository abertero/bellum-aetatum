class_name AbilityDefinition
extends RefCounted

var id: String = ""
var display_name: String = ""
var description: String = ""
var icon: String = ""
var cooldown: float = 0.0
var activation: String = "instant"
var pipeline: AbilityPipeline = null
var metadata: Dictionary = {}


static func from_dictionary(data: Dictionary) -> AbilityDefinition:
	var definition := AbilityDefinition.new()
	definition.id = str(data.get("id", ""))
	definition.display_name = str(data.get("display_name", ""))
	definition.description = str(data.get("description", ""))
	definition.icon = str(data.get("icon", ""))
	definition.cooldown = float(data.get("cooldown", 0.0))
	definition.activation = str(data.get("activation", "instant"))

	definition.pipeline = _resolve_pipeline(data)

	var metadata_data: Variant = data.get("metadata", {})
	if metadata_data is Dictionary:
		definition.metadata = metadata_data.duplicate()

	return definition


static func _resolve_pipeline(data: Dictionary) -> AbilityPipeline:
	var pipeline_data: Variant = data.get("pipeline", {})
	if pipeline_data is Dictionary and pipeline_data.has("nodes"):
		return AbilityPipeline.from_dictionary(pipeline_data)

	var components_data: Variant = data.get("components", [])
	if components_data is Array and components_data.size() > 0:
		return AbilityPipeline.from_components(components_data)

	return AbilityPipeline.new()
