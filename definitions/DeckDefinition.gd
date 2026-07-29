class_name DeckDefinition
extends RefCounted

var card_ids: Array[String] = []


static func from_dictionary(data: Dictionary) -> DeckDefinition:
	var definition := DeckDefinition.new()
	if data.has("card_ids"):
		for id_val in data["card_ids"]:
			definition.card_ids.append(str(id_val))
	return definition
