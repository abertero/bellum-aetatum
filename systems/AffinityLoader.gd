class_name AffinityLoader
extends RefCounted


static func load_affinities(registry: AffinityRegistry, file_path: String) -> void:
	var data: Variant = JsonLoader.load_json(file_path)
	
	if data == null:
		push_error("AffinityLoader: Failed to load affinities from '%s'" % file_path)
		return
	
	if not data is Dictionary:
		push_error("AffinityLoader: Invalid data format in '%s'" % file_path)
		return
	
	if not data.has("affinities"):
		push_error("AffinityLoader: Missing 'affinities' key in '%s'" % file_path)
		return
	
	var affinities_data: Array = data["affinities"]
	if not affinities_data is Array:
		push_error("AffinityLoader: 'affinities' must be an array in '%s'" % file_path)
		return
	
	for affinity_data in affinities_data:
		if not affinity_data is Dictionary:
			push_error("AffinityLoader: Invalid affinity data format in '%s'" % file_path)
			continue
		
		var affinity: AffinityDefinition = AffinityDefinition.from_dictionary(affinity_data)
		registry.register(affinity)
