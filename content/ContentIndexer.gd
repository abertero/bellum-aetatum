class_name ContentIndexer
extends RefCounted

var _cards: Array[UnitDefinition] = []
var _projectiles: Array[ProjectileDefinition] = []
var _personalities: Array[AIPersonalityDefinition] = []
var _game_modes: Array[GameModeDefinition] = []


func set_cards(cards: Array[UnitDefinition]) -> void:
	_cards = cards


func set_projectiles(projectiles: Array[ProjectileDefinition]) -> void:
	_projectiles = projectiles


func set_personalities(personalities: Array[AIPersonalityDefinition]) -> void:
	_personalities = personalities


func set_game_modes(game_modes: Array[GameModeDefinition]) -> void:
	_game_modes = game_modes


func build_indexes() -> ContentIndexes:
	var indexes := ContentIndexes.new()
	_index_cards_by_affinity(indexes)
	_index_cards_by_cost(indexes)
	_index_projectiles_by_type(indexes)
	_index_personalities(indexes)
	_index_game_modes(indexes)
	return indexes


func _index_cards_by_affinity(indexes: ContentIndexes) -> void:
	for card in _cards:
		if card.affinity_id == "":
			continue
		if not indexes.cards_by_affinity.has(card.affinity_id):
			indexes.cards_by_affinity[card.affinity_id] = []
		indexes.cards_by_affinity[card.affinity_id].append(card.id)


func _index_cards_by_cost(indexes: ContentIndexes) -> void:
	for card in _cards:
		if not indexes.cards_by_cost.has(card.cost):
			indexes.cards_by_cost[card.cost] = []
		indexes.cards_by_cost[card.cost].append(card.id)


func _index_projectiles_by_type(indexes: ContentIndexes) -> void:
	for projectile in _projectiles:
		if projectile.projectile_type == "":
			continue
		if not indexes.projectiles_by_type.has(projectile.projectile_type):
			indexes.projectiles_by_type[projectile.projectile_type] = []
		indexes.projectiles_by_type[projectile.projectile_type].append(projectile.id)


func _index_personalities(indexes: ContentIndexes) -> void:
	for personality in _personalities:
		indexes.ai_personalities[personality.id] = personality


func _index_game_modes(indexes: ContentIndexes) -> void:
	for game_mode in _game_modes:
		indexes.game_modes[game_mode.id] = game_mode
