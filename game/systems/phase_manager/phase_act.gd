extends Phase
class_name PhaseAct


func enter_state() -> void:
	super()
	Global.battle_stage.commands_this_turn.clear()
	if Global.active_mech == Global.npc_mech:
		Global.active_mech.agent.act()
	#else:
		#Global.active_mech.
	pass


func exit_state() -> void:
	super()
	pass
