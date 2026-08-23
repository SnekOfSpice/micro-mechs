extends Command
class_name CommandSpin


# Called when the node enters the scene tree for the first time.
func _init() -> void:#() -> void:
	command_name = "spin"



func execute() -> bool:
	for target in targets:
		await target.rotate_animation(360).finished
		target.rotation_degrees = 0
	return true

func undo() -> bool:
	for target in targets:
		target.rotation_degrees = 360
		await target.rotate_animation(0).finished
	return true
