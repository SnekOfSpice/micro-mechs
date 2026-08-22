extends PanelContainer
class_name MechStatusContainer


var tracking_mech : Mech:
	set(value):
		tracking_mech = value
		if value:
			display_mech_state(value)

func _ready() -> void:
	EventBus.combat_stats_changed.connect(display_mech_state)


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
	
	%Actions.text = str(mech.combat_stats.actions_left)
	
