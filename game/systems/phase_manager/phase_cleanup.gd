extends Phase
class_name PhaseCleanup


func enter_state() -> void:
	Global.active_mech.reduce_heat_passive()
	super()
	pass


func exit_state() -> void:
	super()
	pass
