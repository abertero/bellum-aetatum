class_name ContentPipeline
extends RefCounted

var _validator: ContentValidator = null
var _indexer: ContentIndexer = null
var _report: ContentReport = null
var _indexes: ContentIndexes = null
var _context: ValidationContext = null

var _cards: Array[UnitDefinition] = []
var _affinities: Array[AffinityDefinition] = []
var _abilities: Array[AbilityDefinition] = []
var _effects: Array[EffectDefinition] = []
var _projectiles: Array[ProjectileDefinition] = []
var _game_modes: Array[GameModeDefinition] = []
var _personalities: Array[AIPersonalityDefinition] = []


func initialize() -> void:
	_validator = ContentValidator.new()
	_indexer = ContentIndexer.new()
	_report = ContentReport.create()
	_context = ValidationContext.new()


func set_cards(cards: Array[UnitDefinition]) -> void:
	_cards = cards


func set_affinities(affinities: Array[AffinityDefinition]) -> void:
	_affinities = affinities


func set_abilities(abilities: Array[AbilityDefinition]) -> void:
	_abilities = abilities


func set_effects(effects: Array[EffectDefinition]) -> void:
	_effects = effects


func set_projectiles(projectiles: Array[ProjectileDefinition]) -> void:
	_projectiles = projectiles


func set_game_modes(game_modes: Array[GameModeDefinition]) -> void:
	_game_modes = game_modes


func set_personalities(personalities: Array[AIPersonalityDefinition]) -> void:
	_personalities = personalities


func run() -> ContentReport:
	var start_time: int = Time.get_ticks_usec()
	_register_validators()
	var diagnostics: Array[ContentDiagnostic] = _validator.validate_all(_context)
	for diag in diagnostics:
		_report.diagnostics.add(diag)
	var validation_end: int = Time.get_ticks_usec()
	_report.validation_time_ms = float(validation_end - start_time) / 1000.0

	if _report.is_valid():
		_build_indexes()

	var index_end: int = Time.get_ticks_usec()
	_report.index_time_ms = float(index_end - validation_end) / 1000.0
	_update_report_counts()
	return _report


func get_indexes() -> ContentIndexes:
	return _indexes


func get_context() -> ValidationContext:
	return _context


func get_report() -> ContentReport:
	return _report


func _register_validators() -> void:
	var card_validator := CardValidator.new()
	card_validator.initialize(_cards, "res://data/cards/cards.json")
	_validator.register_validator(card_validator)

	var affinity_validator := AffinityValidator.new()
	affinity_validator.initialize(_affinities, "res://data/affinities.json")
	_validator.register_validator(affinity_validator)

	var ability_validator := AbilityValidator.new()
	ability_validator.initialize(_abilities, "res://data/abilities.json")
	_validator.register_validator(ability_validator)

	var effect_validator := EffectValidator.new()
	effect_validator.initialize(_effects, "res://data/effects.json")
	_validator.register_validator(effect_validator)

	var projectile_validator := ProjectileValidator.new()
	projectile_validator.initialize(_projectiles, "res://data/projectiles/projectiles.json")
	_validator.register_validator(projectile_validator)

	var game_mode_validator := GameModeValidator.new()
	game_mode_validator.initialize(_game_modes, "res://data/game_modes.json")
	_validator.register_validator(game_mode_validator)

	var personality_validator := AIPersonalityValidator.new()
	personality_validator.initialize(_personalities, "res://data/ai_personalities.json")
	_validator.register_validator(personality_validator)


func _build_indexes() -> void:
	_indexer.set_cards(_cards)
	_indexer.set_projectiles(_projectiles)
	_indexer.set_personalities(_personalities)
	_indexer.set_game_modes(_game_modes)
	_indexes = _indexer.build_indexes()


func _update_report_counts() -> void:
	_report.total_definitions = (
		_cards.size() + _affinities.size() + _abilities.size()
		+ _effects.size() + _projectiles.size() + _game_modes.size()
		+ _personalities.size()
	)
	_report.definitions_by_type["Cards"] = _cards.size()
	_report.definitions_by_type["Affinities"] = _affinities.size()
	_report.definitions_by_type["Abilities"] = _abilities.size()
	_report.definitions_by_type["Effects"] = _effects.size()
	_report.definitions_by_type["Projectiles"] = _projectiles.size()
	_report.definitions_by_type["GameModes"] = _game_modes.size()
	_report.definitions_by_type["AIPersonalities"] = _personalities.size()
	if _indexes != null:
		_report.index_statistics = _indexes.get_statistics()
