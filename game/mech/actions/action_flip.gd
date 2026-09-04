extends Action
class_name ActionFlip


func do():
	owner.command_flip()


func can_do() -> CanDoResult:
	return CanDoResult.CAN_DO
