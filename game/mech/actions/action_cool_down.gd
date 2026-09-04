extends Action
class_name ActionCoolDown


func do():
	owner.command_cool_down()


func can_do() -> CanDoResult:
	if not owner.combat_stats:
		return CanDoResult.NO_COMBAT_STATS_ERR
	if owner.combat_stats.actions_left <= 0:
		return CanDoResult.OUT_OF_ACTIONS
	return CanDoResult.CAN_DO
