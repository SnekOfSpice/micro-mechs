extends Phase
class_name PhasePassToOther


func enter_state() -> void:
	print("pass to other")
	Global.active_mech = Global.get_other_mech(Global.active_mech)
	super()
	pass


func exit_state() -> void:
	super()
	pass
