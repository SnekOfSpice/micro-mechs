extends Marker3D


var target : Node3D


func _process(delta: float) -> void:
	global_position = global_position.move_toward(target.global_position, 200 * delta)
