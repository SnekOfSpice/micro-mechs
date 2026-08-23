extends Command
class_name CommandStomp

func execute() -> bool:
	for target : Mech in targets:
		await target.stomp()
	return true

func undo() -> bool:
	return true
