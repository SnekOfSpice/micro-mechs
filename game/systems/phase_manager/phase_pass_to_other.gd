extends Phase
class_name PhasePassToOther


func enter_state() -> void:
	Global.battle_stage.commands_this_turn.clear()
	Global.battle_stage.commands_begun_this_turn.clear()
	Global.active_mech = Global.get_other_mech(Global.active_mech)
	Global.active_mech.refill_actions()
	super()
	pass


func exit_state() -> void:
	super()
	pass
