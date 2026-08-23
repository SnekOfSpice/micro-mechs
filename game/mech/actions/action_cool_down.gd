extends Action
class_name ActionCoolDown


func do():
	owner.command_cool_down()


func can_do() -> bool:
	return true
