class_name ContentDiagnostics
extends RefCounted

var _diagnostics: Array[ContentDiagnostic] = []


func add(diagnostic: ContentDiagnostic) -> void:
	_diagnostics.append(diagnostic)


func add_all(diagnostics: Array[ContentDiagnostic]) -> void:
	for diagnostic in diagnostics:
		_diagnostics.append(diagnostic)


func get_all() -> Array[ContentDiagnostic]:
	return _diagnostics.duplicate()


func get_errors() -> Array[ContentDiagnostic]:
	var result: Array[ContentDiagnostic] = []
	for diag in _diagnostics:
		if diag.severity == ContentDiagnostic.Severity.ERROR:
			result.append(diag)
	return result


func get_warnings() -> Array[ContentDiagnostic]:
	var result: Array[ContentDiagnostic] = []
	for diag in _diagnostics:
		if diag.severity == ContentDiagnostic.Severity.WARNING:
			result.append(diag)
	return result


func get_infos() -> Array[ContentDiagnostic]:
	var result: Array[ContentDiagnostic] = []
	for diag in _diagnostics:
		if diag.severity == ContentDiagnostic.Severity.INFO:
			result.append(diag)
	return result


func get_error_count() -> int:
	var count: int = 0
	for diag in _diagnostics:
		if diag.severity == ContentDiagnostic.Severity.ERROR:
			count += 1
	return count


func get_warning_count() -> int:
	var count: int = 0
	for diag in _diagnostics:
		if diag.severity == ContentDiagnostic.Severity.WARNING:
			count += 1
	return count


func get_info_count() -> int:
	var count: int = 0
	for diag in _diagnostics:
		if diag.severity == ContentDiagnostic.Severity.INFO:
			count += 1
	return count


func has_errors() -> bool:
	return get_error_count() > 0


func get_count() -> int:
	return _diagnostics.size()


func clear() -> void:
	_diagnostics.clear()


func format_all() -> String:
	var text: String = ""
	for diag in _diagnostics:
		text += diag.format() + "\n"
	return text
