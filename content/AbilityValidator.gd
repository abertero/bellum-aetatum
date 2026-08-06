class_name AbilityValidator
extends DefinitionValidator

var _abilities: Array[AbilityDefinition] = []
var _file_path: String = ""


func initialize(abilities: Array[AbilityDefinition], file_path: String) -> void:
	_abilities = abilities
	_file_path = file_path


func get_definition_type() -> String:
	return "Ability"


func validate(context: ValidationContext) -> Array[ContentDiagnostic]:
	var diagnostics: Array[ContentDiagnostic] = []
	var seen_ids: Dictionary = {}

	for ability in _abilities:
		_validate_ability(ability, context, seen_ids, diagnostics)

	return diagnostics


func _validate_ability(
	ability: AbilityDefinition,
	context: ValidationContext,
	seen_ids: Dictionary,
	diagnostics: Array[ContentDiagnostic]
) -> void:
	if ability.id == "":
		diagnostics.append(ContentDiagnostic.create_error(
			"(unknown)", "Ability", "Ability has empty id", _file_path, -1,
			"Add a unique id to the ability definition"
		))
		return

	if seen_ids.has(ability.id):
		diagnostics.append(ContentDiagnostic.create_error(
			ability.id, "Ability", "Duplicate ability id", _file_path, -1,
			"Remove the duplicate ability or change its id"
		))
		return

	seen_ids[ability.id] = true
	context.ability_ids.append(ability.id)
	_validate_ability_fields(ability, diagnostics)
	_validate_pipeline(ability, context, diagnostics)


func _validate_ability_fields(ability: AbilityDefinition, diagnostics: Array[ContentDiagnostic]) -> void:
	if ability.cooldown < 0.0:
		diagnostics.append(ContentDiagnostic.create_error(
			ability.id, "Ability", "Ability has negative cooldown: %.1f" % ability.cooldown,
			_file_path, -1, "Set cooldown to a non-negative value"
		))

	if ability.display_name == "":
		diagnostics.append(ContentDiagnostic.create_warning(
			ability.id, "Ability", "Ability has empty display_name", _file_path, -1,
			"Add a display name to the ability"
		))


func _validate_pipeline(
	ability: AbilityDefinition,
	context: ValidationContext,
	diagnostics: Array[ContentDiagnostic]
) -> void:
	if ability.pipeline == null:
		return
	for node in ability.pipeline.nodes:
		_validate_node(ability.id, node, context, diagnostics)


func _validate_node(
	ability_id: String,
	node: AbilityPipelineNode,
	context: ValidationContext,
	diagnostics: Array[ContentDiagnostic]
) -> void:
	var comp_type: String = node.component_data.get("type", "")
	match comp_type:
		"ApplyEffectComponent":
			_validate_effect_ref(ability_id, node, context, diagnostics)
		"SpawnProjectileComponent":
			_validate_projectile_ref(ability_id, node, context, diagnostics)


func _validate_effect_ref(
	ability_id: String,
	node: AbilityPipelineNode,
	context: ValidationContext,
	diagnostics: Array[ContentDiagnostic]
) -> void:
	var effect_id: String = node.component_data.get("effect_id", "")
	if effect_id == "":
		return
	context.ability_effect_refs[ability_id] = effect_id


func _validate_projectile_ref(
	ability_id: String,
	node: AbilityPipelineNode,
	context: ValidationContext,
	diagnostics: Array[ContentDiagnostic]
) -> void:
	var projectile_id: String = node.component_data.get("projectile_id", "")
	if projectile_id == "":
		return
	context.ability_projectile_refs[ability_id] = projectile_id
