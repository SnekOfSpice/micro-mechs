extends Camera2D



func _process(delta: float) -> void:
	if not Global.player_mech:
		return
	if not Global.npc_mech:
		return
	
	var target_pos : Vector2 = Global.npc_mech.global_position.lerp(Global.player_mech.global_position, 0.5)
	global_position = global_position.move_toward(target_pos, delta * 400)
	
	if not (Global.player_mech.is_entirely_on_screen()
		and Global.npc_mech.is_entirely_on_screen()):
		zoom.x -= 1.0 * delta
		zoom.y -= 1.0 * delta
	elif (Global.player_mech.too_much_dead_space()
		and Global.npc_mech.too_much_dead_space()):
		zoom.x += 1.0 * delta
		zoom.y += 1.0 * delta
	
