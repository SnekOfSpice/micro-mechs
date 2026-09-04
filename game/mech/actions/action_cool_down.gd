extends Action
class_name ActionCoolDown


func do():
	owner.command_cool_down()


func can_do() -> CanDoResult:
	if owner.combat_stats.actions_left <= 0:
		return CanDoResult.OUT_OF_ACTIONS
	return CanDoResult.CAN_DO
