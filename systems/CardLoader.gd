class_name CardLoader
extends RefCounted


static func load_cards(file_path: String) -> Array[UnitDefinition]:
	var result: Array[UnitDefinition] = []
	var data: Variant = JsonLoader.load_json(file_path)

	if data == null or not data is Dictionary:
		return result

	if not data.has("cards"):
		return result

	var cards_data: Variant = data["cards"]
	if not cards_data is Array:
		return result

	for card_data in cards_data:
		if card_data is Dictionary:
			var card: UnitDefinition = UnitDefinition.from_dictionary(card_data)
			result.append(card)

	return result
