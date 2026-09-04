extends Action
class_name ActionStomp


func do():
	owner.command_stomp()


func can_do() -> CanDoResult:
	if owner.combat_stats.actions_left <= 0:
		return CanDoResult.OUT_OF_ACTIONS
	if owner.is_in_front_of_other_mech():
		return CanDoResult.CAN_DO
	else:
		return CanDoResult.OUT_OF_RANGE
