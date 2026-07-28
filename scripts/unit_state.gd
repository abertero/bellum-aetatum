class_name UnitState
extends RefCounted

enum State {
	MOVING,
	WAITING,
	BLOCKED,
	ATTACKING,
	DEAD
}


static func to_str(state: State) -> String:
	match state:
		State.MOVING:
			return "Moving"
		State.WAITING:
			return "Waiting"
		State.BLOCKED:
			return "Blocked"
		State.ATTACKING:
			return "Attacking"
		State.DEAD:
			return "Dead"
		_:
			return "Unknown"
