extends Node3D



func _process(delta: float) -> void:
	if not Global.player_mech:
		return
	var target_pos : Vector3 = Global.player_mech.global_position
	global_position.z = global_position.move_toward(target_pos, delta * 400).z

	
