extends Command
class_name CommandMove


var spots_to_move : int
#var initial_spot : int
var speed := 0.1

func _init() -> void:
	command_name = "move"


func execute() -> bool:
	for target : Mech in targets:
		#initial_spot = target.get_spot()
		var target_position := target.get_spot() + spots_to_move
		await target.move_to_index(target_position, get_duration())
	return true


func get_duration() -> float:
	var distance_in_mechs : float = abs(spots_to_move) / float(Mech.WIDTH)
	return distance_in_mechs / speed
