class_name PlayCardCommand
extends GameCommand

var card_id: String = ""
var spawn_position: Vector2 = Vector2.ZERO
var target_position: Vector2 = Vector2.ZERO
var team: String = "player"
var card_definition: UnitDefinition = null
var parent: Node = null


static func create(
	p_card: UnitDefinition,
	p_spawn: Vector2,
	p_target: Vector2,
	p_parent: Node,
	p_team: String = "player",
	p_metadata: Dictionary = {}
) -> PlayCardCommand:
	var cmd := PlayCardCommand.new()
	cmd.card_definition = p_card
	cmd.card_id = p_card.id if p_card != null else ""
	cmd.spawn_position = p_spawn
	cmd.target_position = p_target
	cmd.parent = p_parent
	cmd.team = p_team
	cmd.metadata = p_metadata.duplicate()
	return cmd


func get_command_type() -> String:
	return "PlayCardCommand"


func serialize() -> Dictionary:
	var data: Dictionary = super.serialize()
	data["card_id"] = card_id
	data["spawn_position"] = {"x": spawn_position.x, "y": spawn_position.y}
	data["target_position"] = {"x": target_position.x, "y": target_position.y}
	data["team"] = team
	return data


func deserialize(data: Dictionary) -> void:
	super.deserialize(data)
	card_id = str(data.get("card_id", ""))
	var sp: Dictionary = data.get("spawn_position", {})
	spawn_position = Vector2(float(sp.get("x", 0)), float(sp.get("y", 0)))
	var tp: Dictionary = data.get("target_position", {})
	target_position = Vector2(float(tp.get("x", 0)), float(tp.get("y", 0)))
	team = str(data.get("team", "player"))
