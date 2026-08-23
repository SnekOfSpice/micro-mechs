extends PanelContainer
class_name MechStatusContainer


var tracking_mech : Mech:
	set(value):
		tracking_mech = value
		if value:
			display_mech_state(value)
			_on_commands_this_turn_changed()

func _ready() -> void:
	EventBus.combat_stats_changed.connect(display_mech_state)
	EventBus.commands_this_turn_changed.connect(_on_commands_this_turn_changed)


func display_mech_state(mech : Mech):
	if mech != tracking_mech:
		return
	for thing : String in [
		"health",
		"heat",
		"energy",
		"rockets",
		"bullets",
	]:
		var node := find_child(thing.capitalize())
		node.max_value = mech.combat_stats.get("%s_max" % thing)
		node.value = mech.combat_stats.get(thing)
	
	


func _on_commands_this_turn_changed():
	var phase := PhaseManager.phase
	%Actions.text = ""
	if not phase is PhaseAct:
		return
	if Global.active_mech != tracking_mech:
		return
	
	%Actions.text = str(Global.active_mech.combat_stats.actions_left - Global.battle_stage.commands_this_turn.size())
