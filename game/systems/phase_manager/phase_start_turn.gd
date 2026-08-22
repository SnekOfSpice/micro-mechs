extends Phase
class_name PhaseStartTurn


var first_turn := true


func enter_state() -> void:
	print("generate energy")
	
	super()
	pass


func exit_state() -> void:
	super()
	if first_turn:
		Global.active_mech.refill_actions(1)
	else:
		Global.active_mech.refill_actions()
	first_turn = false
	pass
