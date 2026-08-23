extends Command
class_name CommandMove


var target_position : Vector2
var initial_position : Vector2
var speed := 10.0

func _init() -> void:
	command_name = "move"


func execute() -> bool:
	for target in targets:
		initial_position = target.position
		await target.move(target_position, get_duration())
	return true


func get_duration() -> float:
	var distance_in_pixels := target_position.distance_to(initial_position)
	var distance_in_mechs : float = distance_in_pixels / float(Mech.WIDTH)
	return distance_in_mechs / speed
