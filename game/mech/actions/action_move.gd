extends Action
class_name ActionMove



var config : LegConfig
var distance : int

func do():
	# TODO fancier: if distance in config is > 1, get a selection for how far to go
	owner.command_move(distance)


func can_do() -> CanDoResult:
	if not owner.combat_stats:
		return CanDoResult.NO_COMBAT_STATS_ERR
	if owner.combat_stats.actions_left <= 0:
		return CanDoResult.OUT_OF_ACTIONS
	if owner.is_overheated():
		return CanDoResult.OVERHEATED #abs(distance) <= 1
	
	var forward_data = Global.battle_stage.get_forward_data(owner.get_spot(), owner.flipped, distance)
	if forward_data is BattleStage.TileOutOfBounds:
		return CanDoResult.EDGE_OF_ARENA
	if forward_data is Mech:
		return CanDoResult.MECH_IN_SPOT
	
	if config.movement_type == LegConfig.MovementType.WALK:
		for i in range(1 * sign(distance), distance + 1):
			var step_data = Global.battle_stage.get_forward_data(owner.get_spot(), owner.flipped, i)
			if step_data != null:
				return CanDoResult.MECH_IN_SPOT
	return CanDoResult.CAN_DO
