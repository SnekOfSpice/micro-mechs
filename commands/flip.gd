extends Command
class_name CommandFlip



func _init() -> void:
	command_name = "flip"


func execute() -> bool:
	for target : Mech in targets:
		await target.flip()
	return true
