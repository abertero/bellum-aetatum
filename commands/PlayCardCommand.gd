class_name PlayCardCommand
extends GameCommand

var card_definition: UnitDefinition
var spawn_position: Vector2
var target_position: Vector2
var parent: Node
var team: String


static func create(
	p_card: UnitDefinition,
	p_spawn: Vector2,
	p_target: Vector2,
	p_parent: Node,
	p_team: String = "player",
	p_metadata: Dictionary = {}
) -> PlayCardCommand:
	var cmd := PlayCardCommand.new(p_metadata)
	cmd.card_definition = p_card
	cmd.spawn_position = p_spawn
	cmd.target_position = p_target
	cmd.parent = p_parent
	cmd.team = p_team
	return cmd
