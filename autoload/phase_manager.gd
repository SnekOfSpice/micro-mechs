## Manager Class for the Phase System of the game, for easy transitions between
## different Phases. Manages its children as different Phases. Children must be
## instances of [Phase] class, or extending from it.
extends Node
#TODO: refactor the phase_manager out of an autoload so it's separated from
#menu logic, game logic and so on, and not instantiated before it's useful
#class_name PhaseManager


var phase: Phase
var phases: Array[Phase]

func _ready() -> void:
	for child in get_children():
		child.state_machine = self
		phases.append(child)
	phase = phases.front()

## blindly advance to the next phase
func advance_phase():
	var next_phase = (
		phases[wrapi(phases.find(phase) + 1, 0, phases.size())])
	set_phase(next_phase, phase)


func set_phase(new_phase : Phase, previous_phase : Phase = null):
	if previous_phase:
		previous_phase.exit_state()
	phase = new_phase
	
	
	#_update_player_ui()
	
	phase.enter_state()
	EventBus.phase_changed.emit(phase)


#func _update_player_ui():
	#print("UI")
	##var player = Global.get_local_player()
	##if not player:
		##return
	##var phase_string : String = phase.state_name
	##for player_id : int in state_by_player.keys():
		##var player_name : String = Network.connected_players.get(player_id).get("name")
		##var is_ready : bool = state_by_player.get(player_id)
		##var icon_path : String = "res://testing/accept.png" if is_ready else "res://testing/error.png"
		##var icon_bbcode := "[img]%s[/img]" % icon_path
		##phase_string += "\n"
		##phase_string += "%s %s" % [player_name, icon_bbcode]
	##player.ui.set_phase_info(phase_string)



func begin_match():
	set_phase(phases[0])
