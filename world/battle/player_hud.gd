extends Control
class_name PlayerHUD



func _ready() -> void:
	Global.hud = self


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
	
