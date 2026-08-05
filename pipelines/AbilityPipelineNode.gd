class_name AbilityPipelineNode
extends RefCounted

var node_type: String = "component"
var component_data: Dictionary = {}


static func from_dictionary(data: Dictionary) -> AbilityPipelineNode:
	var node := AbilityPipelineNode.new()
	node.node_type = str(data.get("type", "component"))
	var comp_data: Variant = data.get("component", {})
	if comp_data is Dictionary:
		node.component_data = comp_data.duplicate()
	return node


static func from_component_data(data: Dictionary) -> AbilityPipelineNode:
	var node := AbilityPipelineNode.new()
	node.node_type = "component"
	node.component_data = data.duplicate()
	return node
