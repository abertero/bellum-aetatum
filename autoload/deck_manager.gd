extends Node

var _cards: Dictionary = {}
var _player_deck: Array[Dictionary] = []
var _enemy_deck: Array[Dictionary] = []


func _ready() -> void:
	_load_card_database()


func _load_card_database() -> void:
	var data: Variant = JsonLoader.load_json("res://data/cards/cards.json")
	if data == null or not data.has("cards"):
		push_error("DeckManager: failed to load card database")
		return

	for card: Dictionary in data["cards"]:
		_cards[card["id"]] = card


func load_player_deck(deck_path: String) -> Array[Dictionary]:
	_player_deck = _build_deck(deck_path)
	return _player_deck


func load_enemy_deck(deck_path: String) -> Array[Dictionary]:
	_enemy_deck = _build_deck(deck_path)
	return _enemy_deck


func get_player_deck() -> Array[Dictionary]:
	return _player_deck


func get_enemy_deck() -> Array[Dictionary]:
	return _enemy_deck


func _build_deck(deck_path: String) -> Array[Dictionary]:
	var deck: Array[Dictionary] = []
	var data: Variant = JsonLoader.load_json(deck_path)
	if data == null or not data.has("card_ids"):
		push_error("DeckManager: failed to load deck from %s" % deck_path)
		return deck

	for card_id: String in data["card_ids"]:
		if _cards.has(card_id):
			deck.append(_cards[card_id])
		else:
			push_warning("DeckManager: card not found: %s" % card_id)

	return deck
