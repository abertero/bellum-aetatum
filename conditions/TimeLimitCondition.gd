class_name TimeLimitCondition
extends MatchCondition


func check(context: Dictionary) -> bool:
	var elapsed_time: float = context.get("elapsed_match_time", 0.0)
	var time_limit: float = configuration.get("time_limit", 0.0)
	if time_limit <= 0.0:
		return false
	return elapsed_time >= time_limit


func get_description() -> String:
	var limit: float = configuration.get("time_limit", 0.0)
	return "Time Limit (%.0fs)" % limit
