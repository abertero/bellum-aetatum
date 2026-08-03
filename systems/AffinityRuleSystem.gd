class_name AffinityRuleSystem
extends RefCounted

var _default_values: Dictionary = {}
var _relationships: Dictionary = {}


func load_rules(file_path: String) -> void:
	var data: Variant = JsonLoader.load_json(file_path)
	
	if data == null:
		push_error("AffinityRuleSystem: Failed to load rules from '%s'" % file_path)
		return
	
	if not data is Dictionary:
		push_error("AffinityRuleSystem: Invalid data format in '%s'" % file_path)
		return
	
	if data.has("default_values"):
		_default_values = data["default_values"]
	
	if data.has("relationships"):
		var relationships_data: Array = data["relationships"]
		for relationship in relationships_data:
			if not relationship is Dictionary:
				continue
			
			var attacker: String = relationship.get("attacker", "")
			var defender: String = relationship.get("defender", "")
			var attack_modifier: float = relationship.get("attack_modifier", 1.0)
			var defense_modifier: float = relationship.get("defense_modifier", 1.0)
			
			if attacker != "" and defender != "":
				var key: String = "%s_%s" % [attacker, defender]
				_relationships[key] = {
					"attack_modifier": attack_modifier,
					"defense_modifier": defense_modifier
				}


func get_attack_modifiers(attacker_affinity: String, defender_affinity: String) -> CombatModifierCollection:
	var collection := CombatModifierCollection.new()
	
	var key: String = "%s_%s" % [attacker_affinity, defender_affinity]
	
	if _relationships.has(key):
		var relationship: Dictionary = _relationships[key]
		var modifier_value: float = relationship.get("attack_modifier", 1.0)
		
		if not is_equal_approx(modifier_value, 1.0):
			var modifier: CombatModifier = CombatModifier.create_multiply(
				"affinity_attack_%s_vs_%s" % [attacker_affinity, defender_affinity],
				"AffinityRuleSystem",
				modifier_value,
				0,
				"Affinity attack modifier: %s vs %s" % [attacker_affinity, defender_affinity]
			)
			collection.add_modifier(modifier)
	
	return collection


func get_defense_modifiers(attacker_affinity: String, defender_affinity: String) -> CombatModifierCollection:
	var collection := CombatModifierCollection.new()
	
	var key: String = "%s_%s" % [attacker_affinity, defender_affinity]
	
	if _relationships.has(key):
		var relationship: Dictionary = _relationships[key]
		var modifier_value: float = relationship.get("defense_modifier", 1.0)
		
		if not is_equal_approx(modifier_value, 1.0):
			var modifier: CombatModifier = CombatModifier.create_multiply(
				"affinity_defense_%s_vs_%s" % [attacker_affinity, defender_affinity],
				"AffinityRuleSystem",
				modifier_value,
				0,
				"Affinity defense modifier: %s vs %s" % [attacker_affinity, defender_affinity]
			)
			collection.add_modifier(modifier)
	
	return collection


func get_default_attack_advantage() -> float:
	return _default_values.get("attack_advantage", 1.2)


func get_default_attack_disadvantage() -> float:
	return _default_values.get("attack_disadvantage", 0.8)


func get_default_defense_advantage() -> float:
	return _default_values.get("defense_advantage", 0.8)


func get_default_defense_disadvantage() -> float:
	return _default_values.get("defense_disadvantage", 1.2)
