extends Node
class_name MechAgent


var agent_config : AgentConfig


func _ready() -> void:
	if get_parent() is Mech:
		get_parent().agent = self
	
	agent_config = AgentConfig.get_randomized()


var next_action : Action

func do_next_action():
	if not next_action:
		pick_next_action()
	
	for i in agent_config.action_count:
		if not next_action:
			break
		next_action.do()
		await CommandHandler.command_executed
		pick_next_action()

func pick_next_action() -> void:
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
	
	var picked_action = agent_config.pick_next_action(
		viable_actions,
		mech,
		Global.get_player_mech()
	)
	print("NEXT ACTION IS ", picked_action)
	next_action = picked_action
	
