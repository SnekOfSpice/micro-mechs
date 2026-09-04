extends Camera3D



#func _process(delta: float) -> void:
	#if not Global.player_mech:
		#return
	#if not Global.npc_mech:
		#return
	##return
	#var target_pos : Vector3 = Global.npc_mech.global_position.lerp(Global.player_mech.global_position, 0.5)
	#global_position.z = global_position.move_toward(target_pos, delta * 400).z
	#
	#if not (Global.player_mech.is_entirely_on_screen()
		#and Global.npc_mech.is_entirely_on_screen()):
		#global_position.x -= 10.0 * delta
		##zoom.y -= 1.0 * delta
	#elif (Global.player_mech.too_much_dead_space()
		#and Global.npc_mech.too_much_dead_space()):
		#global_position.x += 10.0 * delta
		##zoom.y += 1.0 * delta
	
