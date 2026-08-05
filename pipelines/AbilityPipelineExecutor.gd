class_name AbilityPipelineExecutor
extends RefCounted


func execute(
	pipeline: AbilityPipeline,
	caster: UnitInstance,
	target: Variant,
	context: Dictionary,
	instance: AbilityInstance
) -> Array[GameCommand]:
	var commands: Array[GameCommand] = []
	for node in pipeline.nodes:
		var node_commands: Array[GameCommand] = _execute_node(node, caster, target, context, instance)
		for command in node_commands:
			commands.append(command)
	return commands


func _execute_node(
	node: AbilityPipelineNode,
	caster: UnitInstance,
	target: Variant,
	context: Dictionary,
	instance: AbilityInstance
) -> Array[GameCommand]:
	if node.node_type != "component":
		return []

	var component: AbilityComponent = _create_component(node.component_data)
	if component == null:
		return []

	instance.record_component(node.component_data.get("type", "unknown"))
	return component.execute(caster, target, context)


func _create_component(component_data: Dictionary) -> AbilityComponent:
	var component_type: String = component_data.get("type", "")
	match component_type:
		"ApplyEffectComponent":
			var comp := ApplyEffectComponent.new()
			comp.initialize(component_data)
			return comp
		"SpawnProjectileComponent":
			var comp := SpawnProjectileComponent.new()
			comp.initialize(component_data)
			return comp
		"GenerateCommandComponent":
			var comp := GenerateCommandComponent.new()
			comp.initialize(component_data)
			return comp
	return null
