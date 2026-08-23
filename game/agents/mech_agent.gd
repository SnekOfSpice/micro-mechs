extends Node
class_name MechAgent


var agent_config : AgentConfig


func _ready() -> void:
	if get_parent() is Mech:
		get_parent().agent = self
	
	CommandHandler.command_executed.connect(on_command_executed)
	
	agent_config = AgentConfig.get_randomized()


func on_command_executed(_command):
	var mech : Mech = Global.active_mech
	if mech != get_parent():
		return
	#print("AGENT DOES")
	var actions : int = mech.combat_stats.actions_left
	if actions - Global.battle_stage.commands_begun_this_turn.size() > 0:
		_pick_next_action()


func act():
	_pick_next_action()

func _pick_next_action():
	var mech : Mech = Global.active_mech
	var action_list := mech.get_action_list()
	var viable_actions : Array[Action] = []
	#action_list.shuffle()
	
	var action_index := 0
	var action : Action
	while action_index < action_list.size():
		action = action_list[action_index]
		var can_do_action : bool = action.can_do() == Action.CanDoResult.CAN_DO
		if can_do_action:
			viable_actions.append(action)
		action_index += 1
	
	if not action:
		push_warning("couldnt find doable action")
		return
	
	agent_config.pick_next_action(
		viable_actions,
		mech,
		Global.get_other_mech(mech)
	).do()
	
