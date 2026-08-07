class_name ContentVersion
extends RefCounted

var version_string: String = "1.0.0"
var schema_version: SchemaVersion = null


static func create(p_version: String, p_schema: SchemaVersion) -> ContentVersion:
	var cv := ContentVersion.new()
	cv.version_string = p_version
	cv.schema_version = p_schema
	return cv


static func current() -> ContentVersion:
	var schema := SchemaVersion.create(1, 0, 0)
	return ContentVersion.create("1.0.0", schema)


func serialize() -> Dictionary:
	return {
		"version": version_string,
		"schema_version": {
			"major": schema_version.major,
			"minor": schema_version.minor,
			"patch": schema_version.patch,
		},
	}


static func deserialize(data: Dictionary) -> ContentVersion:
	var cv := ContentVersion.new()
	cv.version_string = str(data.get("version", "0.0.0"))
	var schema_data: Variant = data.get("schema_version", {})
	if schema_data is Dictionary:
		cv.schema_version = SchemaVersion.from_dictionary(schema_data)
	else:
		cv.schema_version = SchemaVersion.create(0, 0, 0)
	return cv


func is_compatible(other: ContentVersion) -> bool:
	if schema_version == null or other.schema_version == null:
		return false
	return schema_version.is_compatible(other.schema_version)
