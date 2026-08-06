class_name CrossReferenceValidator
extends RefCounted

var _context: ValidationContext
var _file_path: String = ""


func initialize(context: ValidationContext, file_path: String) -> void:
	_context = context
	_file_path = file_path


func validate() -> Array[ContentDiagnostic]:
	var diagnostics: Array[ContentDiagnostic] = []
	_validate_card_affinity_refs(diagnostics)
	_validate_card_projectile_refs(diagnostics)
	_validate_game_mode_personality_refs(diagnostics)
	return diagnostics


func _validate_card_affinity_refs(diagnostics: Array[ContentDiagnostic]) -> void:
	for card_id: String in _context.card_affinity_refs:
		var affinity_id: String = _context.card_affinity_refs[card_id]
		if not _context.has_affinity_id(affinity_id):
			diagnostics.append(ContentDiagnostic.create_error(
				card_id, "Card",
				"Card references unknown affinity '%s'" % affinity_id,
				_file_path, -1,
				"Add the affinity definition or remove the reference"
			))


func _validate_card_projectile_refs(diagnostics: Array[ContentDiagnostic]) -> void:
	for card_id: String in _context.card_projectile_refs:
		var projectile_id: String = _context.card_projectile_refs[card_id]
		if not _context.has_projectile_id(projectile_id):
			diagnostics.append(ContentDiagnostic.create_error(
				card_id, "Card",
				"Card references unknown projectile '%s'" % projectile_id,
				_file_path, -1,
				"Add the projectile definition or remove the reference"
			))


func _validate_game_mode_personality_refs(diagnostics: Array[ContentDiagnostic]) -> void:
	for mode_id: String in _context.game_mode_personality_refs:
		var personality_id: String = _context.game_mode_personality_refs[mode_id]
		if not _context.has_ai_personality_id(personality_id):
			diagnostics.append(ContentDiagnostic.create_error(
				mode_id, "GameMode",
				"GameMode references unknown AI personality '%s'" % personality_id,
				_file_path, -1,
				"Add the AI personality definition or remove the reference"
			))
