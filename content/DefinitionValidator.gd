class_name DefinitionValidator
extends RefCounted


func get_definition_type() -> String:
	return "Unknown"


func validate(context: ValidationContext) -> Array[ContentDiagnostic]:
	return []
