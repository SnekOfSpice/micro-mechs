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
	EventBus.commands_begun_this_turn_changed.connect(_on_commands_begun_this_turn_changed)
	EventBus.commands_this_turn_changed.connect(_on_commands_this_turn_changed)


func display_mech_state(mech : Mech):
	if mech != tracking_mech:
		return
	display_combat_stats(mech.combat_stats)

func display_combat_stats(combat_stats : CombatStats):
	for thing : String in [
		"health",
		"heat",
		"energy",
		"rockets",
		"bullets",
	]:
		var node : Control = find_child(thing.capitalize())
		var max_value = combat_stats.get("%s_max" % thing)
		var value = combat_stats.get(thing)
		node.max_value = max_value
		node.value = value
		
		var label : Label = node.get_child(0)
		label.text = "%s / %s" % [value, max_value]
		
		# bad and hacky
		var icon : TextureRect = find_child("%sIcon" % thing.capitalize())
		if max_value == 0:
			node.modulate.a = 0
			if icon: icon.modulate.a = 0
		else:
			node.modulate.a = 1
			if icon: icon.modulate.a = 1
	
	

## vvv i think my brain dies down here

func _on_commands_this_turn_changed():
	ugh()
func _on_commands_begun_this_turn_changed():
	ugh()
func ugh():
	var phase := PhaseManager.phase
	%Actions.text = ""
	if not phase is PhaseAct:
		return
	if Global.active_mech != tracking_mech:
		return
	
	var a : int = (Global.active_mech.combat_stats.actions_left - 
		Global.battle_stage.commands_begun_this_turn.size())
	%Actions.text = Global.get_uses_string(a,
		2
	)
