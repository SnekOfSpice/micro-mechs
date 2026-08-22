extends Resource
class_name PatternResolverBundle


var resources : Dictionary[Inventory.Items, int] = {}
var starting_resources : Dictionary[Inventory.Items, int] = {}

enum FailResult {
	NONE,
	NULL_PATTERN,
	INSUFFICIENT_INPUTS,
}
var fail_result := FailResult.NONE


func _init() -> void:
	resources = Global.lobby_root.inventory.content.duplicate()
	starting_resources = Global.lobby_root.inventory.content.duplicate()


func has_succeeded() -> bool:
	return fail_result == PatternResolverBundle.FailResult.NONE


func matches_inputs(pattern : PatternData) -> bool:
	if not pattern:
		fail_result = FailResult.NULL_PATTERN
		return false
	var inputs = pattern.inputs
	for needed_resource : Inventory.Items in inputs.keys():
		if resources.get(needed_resource, 0) < inputs.get(needed_resource):
			fail_result = FailResult.INSUFFICIENT_INPUTS
			return false
	fail_result = FailResult.NONE
	return true


## apply_to_inventory is a flag to set if we want to actually
## save the results of the bundle to the inventories
## set it to false if you want to use the bundle for previews
func handle_pattern(pattern : PatternData, apply_to_inventory := true) -> void:
	var inputs = pattern.inputs
	var outputs = pattern.outputs
	for needed_resource : Inventory.Items in inputs.keys():
		var current_amount : int = resources.get(needed_resource, 0)
		resources[needed_resource] = current_amount - inputs.get(needed_resource)
	
	for output_res : Inventory.Items in outputs.keys():
		resources.set(output_res, resources.get(output_res, 0) + outputs.get(output_res))
	
	# TODO should this live here?
	if has_succeeded() and apply_to_inventory:
		distribute_resolvement_effects()


## for now this is where the bundle goes to distribute the effects
## one of the test cards works with a global effect thing, so for now
## this is how we split that funnel between resources we give to players
## and  
func distribute_resolvement_effects():
	if not Network.is_host:
		return
	
	# NOTE: currently this system assumes that all pattern effects
	# apply to all players. if we want patterns to affect a non-complete subset
	# of players, we'll need to refactor this (e.g. only the player that played
	# the pattern)
	for resource : Inventory.Items in resources.keys():
		if _is_resource_global(resource):
			Global.lobby_root.command_global_stash_inventory_change_by(
				resource,
				resources.get(resource)
			)
		else:
			Global.lobby_root.command_player_inventory_change_by(
				resource,
				resources.get(resource)
			)


func _is_resource_global(resource : Inventory.Items) -> bool:
	# TODO idk maybe offload this into some config file?
	return resource in [
		Inventory.Items.BUFF_ADDITIONAL_CARD_DRAW,
		Inventory.Items.OIL,
		Inventory.Items.SLUDGE,
		Inventory.Items.METAL,
		Inventory.Items.SCRAP,
	]






# for (debug) visualization only
func readable() -> String:
	var diff : Dictionary
	for resource in resources.keys():
		var output_amount = resources.get(resource)
		var start_amount = starting_resources.get(resource, 0)
		diff.set(resource, output_amount - start_amount)
	return Global.make_resource_list(diff)
