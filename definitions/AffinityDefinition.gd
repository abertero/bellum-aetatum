class_name AffinityDefinition
extends RefCounted

var id: String = ""
var display_name: String = ""
var description: String = ""
var primary_color: Color = Color.WHITE
var icon: String = ""
var background: String = ""


static func from_dictionary(data: Dictionary) -> AffinityDefinition:
	var definition := AffinityDefinition.new()
	definition.id = str(data.get("id", ""))
	definition.display_name = str(data.get("display_name", ""))
	definition.description = str(data.get("description", ""))
	
	var color_data: Variant = data.get("primary_color", "")
	if color_data is String and color_data != "":
		definition.primary_color = Color(color_data)
	
	definition.icon = str(data.get("icon", ""))
	definition.background = str(data.get("background", ""))
	
	return definition
