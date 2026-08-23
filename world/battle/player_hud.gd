extends Control
class_name PlayerHUD



func _ready() -> void:
	Global.hud = self
	EventBus.phase_changed.connect(_on_phase_changed)
	#EventBus.combat_stats_changed.connect(_on_combat_stats_changed)


func _on_phase_changed(phase : Phase):
	%ActionsContainer.hide()
	if not phase is PhaseAct:
		return
	
	if Global.active_mech == Global.player_mech:
		%ActionsContainer.visible = true

#
#func _on_combat_stats_changed(mech : Mech):
	#if mech != Global.player_mech:
		#return
	#
	#%ActionsContainer.visible = mech.combat_stats.actions_left > 0

func register_mechs_to_track(player_mech : Mech, npc_mech : Mech):
	%MechStatusContainer.tracking_mech = player_mech
	%MechStatusContainer2.tracking_mech = npc_mech

func populate_player_actions(actions : Array[Action]):
	for child in %ActionsContainer.get_children():
		child.queue_free()
	
	for action : Action in actions:
		# TODO hook this into a factory
		var button := preload("res://autoload/action_button.tscn").instantiate()
		#button.text = action.resource_name
		%ActionsContainer.add_child(button)
		button.action = action
	

var visualizer_tween : Tween

func visualize_weapon(weapon : WeaponConfig, attacker : Mech):
	if visualizer_tween:
		visualizer_tween.kill()
	var is_player_attacker : bool = attacker == Global.player_mech
	%AttackInfoDisplay.render(weapon, AttackInfoDisplay.Perspective.ATTACKER if is_player_attacker else AttackInfoDisplay.Perspective.DEFENDER)
	%DefenderInfoDisplay.render(weapon, AttackInfoDisplay.Perspective.ATTACKER if not is_player_attacker else AttackInfoDisplay.Perspective.DEFENDER)
	
	var attack_width : float = %AttackInfoDisplay.size.x
	var defender_width : float = %DefenderInfoDisplay.size.x
	var margin := 10.0
	
	%AttackInfoDisplay.position.x = -margin + - attack_width * 0.5
	%DefenderInfoDisplay.position.x = size.x + defender_width * 0.5
	
	await RenderingServer.frame_post_draw
	visualizer_tween = create_tween()
	visualizer_tween.set_parallel()
	visualizer_tween.tween_property(%AttackInfoDisplay, "position:x", attack_width - margin, 1).set_trans(Tween.TRANS_CUBIC)
	visualizer_tween.tween_property(%DefenderInfoDisplay, "position:x", size.x - margin - defender_width, 1).set_trans(Tween.TRANS_CUBIC)

func hide_weapon_visualizer():
	if visualizer_tween:
		visualizer_tween.kill()
	%AttackInfoDisplay.position.x = - %AttackInfoDisplay.size.x
	%DefenderInfoDisplay.position.x = size.x +  %DefenderInfoDisplay.size.x
