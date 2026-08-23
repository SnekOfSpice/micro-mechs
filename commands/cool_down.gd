extends Command
class_name CommandCoolDown

func execute() -> bool:
	for target : Mech in targets:
		target.cool_down()
	return true

func undo() -> bool:
	return true
