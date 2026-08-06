class_name ContentValidator
extends RefCounted

var _validators: Array[DefinitionValidator] = []


func register_validator(validator: DefinitionValidator) -> void:
	_validators.append(validator)


func validate_all(context: ValidationContext) -> Array[ContentDiagnostic]:
	var diagnostics: Array[ContentDiagnostic] = []

	for validator in _validators:
		var results: Array[ContentDiagnostic] = validator.validate(context)
		for result in results:
			diagnostics.append(result)

	var cross_ref := CrossReferenceValidator.new()
	cross_ref.initialize(context, "")
	var cross_results: Array[ContentDiagnostic] = cross_ref.validate()
	for result in cross_results:
		diagnostics.append(result)

	return diagnostics


func get_validator_count() -> int:
	return _validators.size()
