extends Action
class_name ActionCoolDown


func do():
	owner.command_cool_down()


func can_do() -> CanDoResult:
	return CanDoResult.CAN_DO
