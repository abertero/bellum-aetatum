class_name ContentReport
extends RefCounted

var diagnostics: ContentDiagnostics = null
var validation_time_ms: float = 0.0
var index_time_ms: float = 0.0
var total_definitions: int = 0
var definitions_by_type: Dictionary = {}
var index_statistics: Dictionary = {}


static func create() -> ContentReport:
	var report := ContentReport.new()
	report.diagnostics = ContentDiagnostics.new()
	return report


func is_valid() -> bool:
	return not diagnostics.has_errors()


func get_summary() -> String:
	var text: String = "Content Report\n"
	text += "================\n"
	text += "Definitions: %d\n" % total_definitions
	for type_name: String in definitions_by_type:
		text += "  %s: %d\n" % [type_name, definitions_by_type[type_name]]
	text += "Validation: %.1fms\n" % validation_time_ms
	text += "Indexing: %.1fms\n" % index_time_ms
	text += "Errors: %d\n" % diagnostics.get_error_count()
	text += "Warnings: %d\n" % diagnostics.get_warning_count()
	text += "Info: %d\n" % diagnostics.get_info_count()
	if not index_statistics.is_empty():
		text += "Indexes:\n"
		for index_name: String in index_statistics:
			text += "  %s: %d entries\n" % [index_name, index_statistics[index_name]]
	return text


func get_error_summary() -> String:
	var errors: Array[ContentDiagnostic] = diagnostics.get_errors()
	if errors.is_empty():
		return "No errors."
	var text: String = "Errors (%d):\n" % errors.size()
	for error in errors:
		text += "  " + error.format() + "\n"
	return text


func get_warning_summary() -> String:
	var warnings: Array[ContentDiagnostic] = diagnostics.get_warnings()
	if warnings.is_empty():
		return "No warnings."
	var text: String = "Warnings (%d):\n" % warnings.size()
	for warning in warnings:
		text += "  " + warning.format() + "\n"
	return text
