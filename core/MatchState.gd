class_name MatchState
extends RefCounted

enum State {
	LOADING,
	INITIALIZING,
	COUNTDOWN,
	RUNNING,
	PAUSED,
	VICTORY,
	DEFEAT,
	DRAW,
	FINISHED,
}


static func to_str(state: int) -> String:
	match state:
		State.LOADING:
			return "Loading"
		State.INITIALIZING:
			return "Initializing"
		State.COUNTDOWN:
			return "Countdown"
		State.RUNNING:
			return "Running"
		State.PAUSED:
			return "Paused"
		State.VICTORY:
			return "Victory"
		State.DEFEAT:
			return "Defeat"
		State.DRAW:
			return "Draw"
		State.FINISHED:
			return "Finished"
	return "Unknown"


static func is_terminal(state: int) -> bool:
	return state == State.VICTORY or state == State.DEFEAT or state == State.DRAW or state == State.FINISHED
