extends Action
class_name ActionCoolDown


func do():
	super()
	owner.command_cool_down()


func can_do() -> bool:
	return true
