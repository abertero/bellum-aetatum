class_name AbilityPipeline
extends RefCounted

var nodes: Array[AbilityPipelineNode] = []


static func from_dictionary(data: Dictionary) -> AbilityPipeline:
	var pipeline := AbilityPipeline.new()
	var nodes_data: Variant = data.get("nodes", [])
	if nodes_data is Array:
		for node_data in nodes_data:
			if node_data is Dictionary:
				var node: AbilityPipelineNode = AbilityPipelineNode.from_dictionary(node_data)
				pipeline.nodes.append(node)
	return pipeline


static func from_components(components: Array) -> AbilityPipeline:
	var pipeline := AbilityPipeline.new()
	for component_data in components:
		if component_data is Dictionary:
			var node: AbilityPipelineNode = AbilityPipelineNode.from_component_data(component_data)
			pipeline.nodes.append(node)
	return pipeline


func get_node_count() -> int:
	return nodes.size()
