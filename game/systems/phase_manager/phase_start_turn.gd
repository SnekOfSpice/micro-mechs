extends Phase
class_name PhaseStartTurn


var first_turn := true


func enter_state() -> void:
	for mech : Mech in Global.battle_stage.combat_order:
		print("REFILLING ", mech)
		mech.generate_energy()
		mech.refill_actions()
		mech.generate_intent()
	Global.hud.begin_turn()
	
	super()
	pass


func exit_state() -> void:
	super()
	if first_turn:
		Global.player_mech.refill_actions(1)
	first_turn = false
	pass
