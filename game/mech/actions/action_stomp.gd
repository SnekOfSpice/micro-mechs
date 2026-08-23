extends Action
class_name ActionStomp


func do():
	owner.command_stomp()


func can_do() -> bool:
	return owner.is_in_front_of_other_mech()
