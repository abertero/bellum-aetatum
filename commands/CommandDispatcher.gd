class_name CommandDispatcher
extends RefCounted

var _spawn_system: SpawnSystem
var _attack_system: AttackSystem
var _economy_system: EconomySystem


func initialize(spawn_system: SpawnSystem, attack_system: AttackSystem, economy_system: EconomySystem) -> void:
	_spawn_system = spawn_system
	_attack_system = attack_system
	_economy_system = economy_system


func dispatch(command: GameCommand) -> Variant:
	if command is PlayCardCommand:
		return _dispatch_play_card(command as PlayCardCommand)
	if command is AttackCommand:
		return _dispatch_attack(command as AttackCommand)
	push_error("CommandDispatcher: unhandled command type")
	return null


func _dispatch_play_card(command: PlayCardCommand) -> Variant:
	if not _validate_play_card(command):
		return null
	_spend_resource(command)
	return _spawn_system.spawn_unit(
		command.card_definition,
		command.spawn_position,
		command.target_position,
		command.parent,
		command.team
	)


func _validate_play_card(command: PlayCardCommand) -> bool:
	var cost: int = command.card_definition.cost
	if cost <= 0:
		return true
	return _economy_system.can_afford(command.team, "imperium", cost)


func _spend_resource(command: PlayCardCommand) -> void:
	var cost: int = command.card_definition.cost
	if cost > 0:
		_economy_system.spend(command.team, "imperium", cost)


func _dispatch_attack(command: AttackCommand) -> DamageAction:
	return _attack_system.execute(command.attacker, command.target)
