extends Node

var _cards: Dictionary = {}
var _player_deck: Array[UnitDefinition] = []
var _enemy_deck: Array[UnitDefinition] = []


func _ready() -> void:
	_load_card_database()


func _load_card_database() -> void:
	var data: Variant = JsonLoader.load_json("res://data/cards/cards.json")
	if data == null or not data.has("cards"):
		push_error("DeckSystem: failed to load card database")
		return

	for card: Dictionary in data["cards"]:
		var unit_def: UnitDefinition = UnitDefinition.from_dictionary(card)
		_cards[unit_def.id] = unit_def


func load_player_deck(deck_path: String) -> Array[UnitDefinition]:
	_player_deck = _build_deck(deck_path)
	return _player_deck


func load_enemy_deck(deck_path: String) -> Array[UnitDefinition]:
	_enemy_deck = _build_deck(deck_path)
	return _enemy_deck


func get_player_deck() -> Array[UnitDefinition]:
	return _player_deck


func get_enemy_deck() -> Array[UnitDefinition]:
	return _enemy_deck


func _build_deck(deck_path: String) -> Array[UnitDefinition]:
	var deck: Array[UnitDefinition] = []
	var data: Variant = JsonLoader.load_json(deck_path)
	if data == null:
		push_error("DeckSystem: failed to load deck from %s" % deck_path)
		return deck

	var deck_def: DeckDefinition = DeckDefinition.from_dictionary(data)
	for card_id: String in deck_def.card_ids:
		if _cards.has(card_id):
			deck.append(_cards[card_id])
		else:
			push_warning("DeckSystem: card not found: %s" % card_id)

	return deck
