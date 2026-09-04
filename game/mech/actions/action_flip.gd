extends Action
class_name ActionFlip


func do():
	owner.command_flip()


func can_do() -> CanDoResult:
	if owner.combat_stats.actions_left <= 0:
		return CanDoResult.OUT_OF_ACTIONS
	return CanDoResult.CAN_DO
