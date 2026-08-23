extends Node
class_name MechAgent


func _ready() -> void:
	if get_parent() is Mech:
		get_parent().agent = self


func act():
	var mech : Mech= Global.active_mech
	#print("AGENT DOES")
	var actions : int = mech.combat_stats.actions_left
	var actions_to_do := []
	for i in actions:
		var action_list := mech.get_action_list()
		
		action_list.shuffle()
		
		var action_index := 0
		var action : Action
		while action_index < action_list.size():
			action = action_list[action_index]
			var can_do_action : bool = action.can_do()
			if can_do_action:
				break
			action_index += 1
		
		if not action:
			push_warning("couldnt find doable action")
			break
		
		actions_to_do.append(action)
		
	for action in actions_to_do:
		action.do()
