extends Phase
class_name PhaseEnemyTurn


func enter_state() -> void:
	await Global.battle_stage.do_enemy_actions()
	super()
	pass


func exit_state() -> void:
	super()
	pass
