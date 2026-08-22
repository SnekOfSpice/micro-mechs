extends Node
class_name MechAgent


func _ready() -> void:
	EventBus.phase_changed.connect(_on_phase_changed)



func _on_phase_changed(phase : Phase):
	if Global.active_mech == Global.npc_mech and phase is PhaseAct:
		var mech : Mech= Global.active_mech
		print("AGENT DOES")
		while mech.combat_stats.actions_left > 0:
			var action_list := mech.get_action_list()
			
			var action : Action = action_list.pick_random()
			var can_do_action : bool = action.can_do()
			while not can_do_action:
				action = action_list.pick_random()
				can_do_action = action.can_do()
			
			if action is ActionMove:
				print("AGENT MOVES")
			if action is ActionCoolDown:
				print("AGENT COOLS DOWN")
			if action is ActionWeapon:
				print("AGENT SHOOTS")
			
			action.do()
			await get_tree().process_frame
