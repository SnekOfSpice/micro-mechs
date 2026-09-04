extends Resource
class_name AgentConfig



# randomness := chance to pick a random action
@export var randomness := 0.1
@export var stomp_preference := 0.1
@export var default_attack_chance := 0.2
# heat aversion: does cooldown with a 0 - 100% guarantee in this relative threshold (should be Vec2([0,1], [0,1])
@export var heat_aversion := Vector2(0.7, 0.9)
# optimal range preference: chance to do the following behavior: averages all ranges of all weapons. if it is there, pick a weapon from among them. if not, move towards that spot.
@export var optimal_range_preference := 0.5
# move vs cooldown change when no weapons are in range
@export var move_or_cooldown_chance := 0.5
@export var move_or_cooldown_bias := 0.5


func pick_next_action(viable_action_list : Array[Action],
	executing_mech : Mech,
	target_mech : Mech,
	) -> Action:
	if viable_action_list.size() == 1:
		return viable_action_list.front()
	
	
	for action : Action in viable_action_list:
		if action is ActionWeapon:
			var bounds := executing_mech.get_weapon_attack_bounds(action.config)
			if not Global.player_mech.is_in_range(bounds):
				viable_action_list.erase(action)
	
	
	for action : Action in viable_action_list:
		if action is ActionFlip:
			if executing_mech.is_pointed_at_enemy():
				viable_action_list.erase(action)
			else:
				return action
	
	if executing_mech.combat_stats.heat == 0:
		if viable_action_list.size() > 1:
			for action : Action in viable_action_list:
				if action is ActionCoolDown:
					viable_action_list.erase(action)
	
	viable_action_list.shuffle()
	
	if randf() <= randomness:
		return viable_action_list.pick_random()
	
	if randf() <= stomp_preference:
		for action in viable_action_list:
			if action is ActionStomp:
				return action
	
	if randf() <= default_attack_chance:
		for action in viable_action_list:
			if action is ActionWeapon:
				return action
	
	var relative_heat : float = float(executing_mech.combat_stats.heat) / float(executing_mech.combat_stats.heat_max)
	var aversion_strength := (relative_heat - heat_aversion.x) / (heat_aversion.y - heat_aversion.x)
	if randf() < aversion_strength:
		for action in viable_action_list:
			if action is ActionCoolDown:
				return action
	
	var viable_weapons_by_range : Dictionary[int, int] = {}
	for action in viable_action_list:
		if action is ActionWeapon:
			for i in range(action.config.weapon_range.x, action.config.weapon_range.y + 1):
				if viable_weapons_by_range.keys().has(i):
					viable_weapons_by_range[i] += 1
				else:
					viable_weapons_by_range[i] = 1
	if randf() < optimal_range_preference and not viable_weapons_by_range.is_empty():
		var sorted_counts = viable_weapons_by_range.values().duplicate()
		sorted_counts.sort()
		var optimal_ranges := []
		var highest_count : int = sorted_counts.front()
		for key in viable_weapons_by_range.keys():
			if viable_weapons_by_range.get(key) == highest_count:
				optimal_ranges.append(key)
		
		var distance_between_mechs : int = executing_mech.get_distance_to_spot(target_mech.get_spot())
		if optimal_ranges.has(distance_between_mechs):
			for action in viable_action_list:
				if action is ActionWeapon:
					return action
		else:
			for action in viable_action_list:
				if action is ActionMove:
					if (action.distance + distance_between_mechs) in optimal_ranges:
						return action
			
			var optimal_average : float = 0.0
			for i in optimal_ranges:
				optimal_average += i
			optimal_average /= optimal_ranges.size()
			var direction : int = sign(optimal_average - distance_between_mechs)
			for action in viable_action_list:
				if action is ActionMove:
					if sign(action.distance) == direction:
						return action
	
	
	if randf() < move_or_cooldown_chance:
		if executing_mech.combat_stats.heat == 0: # default to move
			for action in viable_action_list:
				if action is ActionMove:
					return action
		if randf() < move_or_cooldown_bias:
			for action in viable_action_list:
				if action is ActionMove:
					return action
		else:
			for action in viable_action_list:
				if action is ActionCoolDown:
					return action
	
	return viable_action_list.pick_random()


static func get_randomized() -> AgentConfig:
	var config := AgentConfig.new()
	config.randomness = randf()
	config.stomp_preference = randf() * 0.5
	config.default_attack_chance = randf() * 0.95
	config.optimal_range_preference = randf()
	config.move_or_cooldown_chance = randf() * 0.25
	config.move_or_cooldown_bias = randf()
	var x = randf()
	var y = randf()
	config.heat_aversion = Vector2(min(x, y), max(x, y))
	return config
