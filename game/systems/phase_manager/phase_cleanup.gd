extends Phase
class_name PhaseCleanup


func enter_state() -> void:
	Global.active_mech.reduce_heat_passive()
	Global.active_mech.weapon_configs_used_this_turn.clear()
	super()
	pass


func exit_state() -> void:
	super()
	pass
