extends Action
class_name ActionCoolDown


func do():
	super()
	owner.cool_down()


func can_do() -> bool:
	return true
