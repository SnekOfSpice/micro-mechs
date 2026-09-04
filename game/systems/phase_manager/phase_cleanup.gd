extends Phase
class_name PhaseCleanup


func enter_state() -> void:
	Global.player_mech.weapon_configs_used_this_turn.clear()
	super()
	pass


func exit_state() -> void:
	super()
	Global.battle_stage.commands_this_turn.clear()
	Global.battle_stage.clear_commands_begun_this_turn()
	pass
