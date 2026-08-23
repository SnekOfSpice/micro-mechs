extends Command
class_name CommandMove


var initial_position := Vector2.ZERO
var target_position := Vector2.ZERO
var speed := 800.0

func _init() -> void:
	command_name = "move"


func execute() -> bool:
	for target in targets:
		initial_position = target.position
		await target.move_animation(target_position, get_duration()).finished
	return true

func undo() -> bool:
	for target in targets:
		await target.move_animation(initial_position, get_duration()).finished
	return true


func get_duration() -> float:
	return target_position.distance_to(initial_position) / speed
