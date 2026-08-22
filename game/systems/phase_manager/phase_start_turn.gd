extends Phase
class_name PhaseStartTurn


func enter_state() -> void:
	print("generate energy")
	Global.active_mech.refill_actions()
	super()
	pass


func exit_state() -> void:
	super()
	pass
