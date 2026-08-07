class_name SchemaVersion
extends RefCounted

var major: int = 0
var minor: int = 0
var patch: int = 0


static func create(p_major: int, p_minor: int = 0, p_patch: int = 0) -> SchemaVersion:
	var version := SchemaVersion.new()
	version.major = p_major
	version.minor = p_minor
	version.patch = p_patch
	return version


static func from_string(version_str: String) -> SchemaVersion:
	var version := SchemaVersion.new()
	var parts: PackedStringArray = version_str.split(".")
	if parts.size() >= 1:
		version.major = int(parts[0])
	if parts.size() >= 2:
		version.minor = int(parts[1])
	if parts.size() >= 3:
		version.patch = int(parts[2])
	return version


static func from_dictionary(data: Dictionary) -> SchemaVersion:
	var version := SchemaVersion.new()
	version.major = int(data.get("major", 0))
	version.minor = int(data.get("minor", 0))
	version.patch = int(data.get("patch", 0))
	return version


func to_version_string() -> String:
	return "%d.%d.%d" % [major, minor, patch]


func is_compatible(other: SchemaVersion) -> bool:
	return major == other.major and minor >= other.minor


func equals(other: SchemaVersion) -> bool:
	return major == other.major and minor == other.minor and patch == other.patch
