class_name CardValidator
extends DefinitionValidator

var _cards: Array[UnitDefinition] = []
var _file_path: String = ""


func initialize(cards: Array[UnitDefinition], file_path: String) -> void:
	_cards = cards
	_file_path = file_path


func get_definition_type() -> String:
	return "Card"


func validate(context: ValidationContext) -> Array[ContentDiagnostic]:
	var diagnostics: Array[ContentDiagnostic] = []
	var seen_ids: Dictionary = {}

	for card in _cards:
		_validate_card(card, context, seen_ids, diagnostics)

	return diagnostics


func _validate_card(
	card: UnitDefinition,
	context: ValidationContext,
	seen_ids: Dictionary,
	diagnostics: Array[ContentDiagnostic]
) -> void:
	if card.id == "":
		diagnostics.append(ContentDiagnostic.create_error(
			"(unknown)", "Card", "Card has empty id", _file_path, -1,
			"Add a unique id to the card definition"
		))
		return

	if seen_ids.has(card.id):
		diagnostics.append(ContentDiagnostic.create_error(
			card.id, "Card", "Duplicate card id", _file_path, -1,
			"Remove the duplicate card or change its id"
		))
		return

	seen_ids[card.id] = true
	context.card_ids.append(card.id)
	_validate_card_fields(card, diagnostics)
	_record_references(card, context)


func _validate_card_fields(card: UnitDefinition, diagnostics: Array[ContentDiagnostic]) -> void:
	if card.name == "":
		diagnostics.append(ContentDiagnostic.create_warning(
			card.id, "Card", "Card has empty name", _file_path, -1,
			"Add a display name to the card"
		))

	if card.hp <= 0:
		diagnostics.append(ContentDiagnostic.create_error(
			card.id, "Card", "Card has invalid hp: %d" % card.hp, _file_path, -1,
			"Set hp to a positive value"
		))

	if card.cost < 0:
		diagnostics.append(ContentDiagnostic.create_error(
			card.id, "Card", "Card has negative cost: %d" % card.cost, _file_path, -1,
			"Set cost to a non-negative value"
		))

	if card.speed < 0.0:
		diagnostics.append(ContentDiagnostic.create_error(
			card.id, "Card", "Card has negative speed: %.1f" % card.speed, _file_path, -1,
			"Set speed to a non-negative value"
		))

	if card.image != "" and not ResourceLoader.exists(card.image):
		diagnostics.append(ContentDiagnostic.create_warning(
			card.id, "Card", "Card image not found: %s" % card.image, _file_path, -1,
			"Add the image file or remove the image reference"
		))


func _record_references(card: UnitDefinition, context: ValidationContext) -> void:
	if card.affinity_id != "":
		context.card_affinity_refs[card.id] = card.affinity_id

	if card.projectile_id != "":
		context.card_projectile_refs[card.id] = card.projectile_id
