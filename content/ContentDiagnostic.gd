class_name ContentDiagnostic
extends RefCounted

enum Severity { INFO, WARNING, ERROR }

var severity: int = Severity.ERROR
var definition_id: String = ""
var definition_type: String = ""
var file_path: String = ""
var line: int = -1
var message: String = ""
var suggested_fix: String = ""


static func create_error(
	p_id: String,
	p_type: String,
	p_message: String,
	p_file: String = "",
	p_line: int = -1,
	p_fix: String = ""
) -> ContentDiagnostic:
	var diag := ContentDiagnostic.new()
	diag.severity = Severity.ERROR
	diag.definition_id = p_id
	diag.definition_type = p_type
	diag.message = p_message
	diag.file_path = p_file
	diag.line = p_line
	diag.suggested_fix = p_fix
	return diag


static func create_warning(
	p_id: String,
	p_type: String,
	p_message: String,
	p_file: String = "",
	p_line: int = -1,
	p_fix: String = ""
) -> ContentDiagnostic:
	var diag := ContentDiagnostic.new()
	diag.severity = Severity.WARNING
	diag.definition_id = p_id
	diag.definition_type = p_type
	diag.message = p_message
	diag.file_path = p_file
	diag.line = p_line
	diag.suggested_fix = p_fix
	return diag


static func create_info(
	p_id: String,
	p_type: String,
	p_message: String,
	p_file: String = "",
	p_line: int = -1,
	p_fix: String = ""
) -> ContentDiagnostic:
	var diag := ContentDiagnostic.new()
	diag.severity = Severity.INFO
	diag.definition_id = p_id
	diag.definition_type = p_type
	diag.message = p_message
	diag.file_path = p_file
	diag.line = p_line
	diag.suggested_fix = p_fix
	return diag


func get_severity_name() -> String:
	match severity:
		Severity.ERROR:
			return "ERROR"
		Severity.WARNING:
			return "WARNING"
		Severity.INFO:
			return "INFO"
	return "UNKNOWN"


func format() -> String:
	var text: String = "[%s] %s/%s: %s" % [get_severity_name(), definition_type, definition_id, message]
	if file_path != "":
		text += " (file: %s" % file_path
		if line >= 0:
			text += ":%d" % line
		text += ")"
	if suggested_fix != "":
		text += " -> Fix: %s" % suggested_fix
	return text
