class_name CommandDispatcher
extends RefCounted

var _spawn_system: SpawnSystem
var _attack_system: AttackSystem


func initialize(spawn_system: SpawnSystem, attack_system: AttackSystem) -> void:
	_spawn_system = spawn_system
	_attack_system = attack_system


func dispatch(command: GameCommand) -> Variant:
	if command is PlayCardCommand:
		return _dispatch_play_card(command as PlayCardCommand)
	if command is AttackCommand:
		return _dispatch_attack(command as AttackCommand)
	push_error("CommandDispatcher: unhandled command type")
	return null


func _dispatch_play_card(command: PlayCardCommand) -> UnitInstance:
	return _spawn_system.spawn_unit(
		command.card_definition,
		command.spawn_position,
		command.target_position,
		command.parent,
		command.team
	)


func _dispatch_attack(command: AttackCommand) -> DamageAction:
	return _attack_system.execute(command.attacker, command.target)
