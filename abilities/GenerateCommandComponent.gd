class_name GenerateCommandComponent
extends AbilityComponent


func execute(caster: UnitInstance, _target: Variant, _context: Dictionary) -> Array[GameCommand]:
	var command_type: String = configuration.get("command_type", "")
	if command_type == "":
		return []

	match command_type:
		"attack":
			return _create_attack_command(caster)
	return []


func _create_attack_command(caster: UnitInstance) -> Array[GameCommand]:
	var target: UnitInstance = caster.get_current_target()
	if target == null or not is_instance_valid(target):
		return []

	var command: AttackCommand = AttackCommand.create(caster, target)
	return [command]
