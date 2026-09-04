extends Node
class_name MechAgent


var agent_config : AgentConfig


func _ready() -> void:
	if get_parent() is Mech:
		get_parent().agent = self
	
	agent_config = AgentConfig.get_randomized()


func act():
	await _pick_next_action()

func _pick_next_action():
	var mech : Mech = get_parent()
	var action_list := mech.get_action_list()
	var viable_actions : Array[Action] = []
	
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
	
	var next_action = agent_config.pick_next_action(
		viable_actions,
		mech,
		Global.get_player_mech()
	)
	print("NEXT ACTION IS ", next_action)
	mech.combat_stats.actions_left -= 1
	next_action.do()
	await CommandHandler.command_executed
	
