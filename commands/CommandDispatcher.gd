class_name CommandDispatcher
extends RefCounted

var _spawn_system: SpawnSystem
var _attack_system: AttackSystem
var _economy_system: EconomySystem
var _ability_system: AbilitySystem = null


func initialize(p_spawn_system: SpawnSystem, p_attack_system: AttackSystem, p_economy_system: EconomySystem) -> void:
	_spawn_system = p_spawn_system
	_attack_system = p_attack_system
	_economy_system = p_economy_system


func set_ability_system(p_ability_system: AbilitySystem) -> void:
	_ability_system = p_ability_system


func dispatch(command: GameCommand) -> Variant:
	if command is PlayCardCommand:
		return _dispatch_play_card(command as PlayCardCommand)
	if command is AttackCommand:
		return _dispatch_attack(command as AttackCommand)
	if command is AbilityCommand:
		return _dispatch_ability(command as AbilityCommand)
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


func _dispatch_ability(command: AbilityCommand) -> bool:
	if _ability_system == null:
		push_error("CommandDispatcher: AbilitySystem not set")
		return false
	return _ability_system.execute_ability(command.ability_id, command.caster, command.target)
