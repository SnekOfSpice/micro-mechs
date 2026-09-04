extends Action
class_name ActionMove



var config : LegConfig
var distance : int

func do():
	# TODO fancier: if distance in config is > 1, get a selection for how far to go
	owner.command_move(distance)


func can_do() -> CanDoResult:
	if owner.combat_stats.actions_left <= 0:
		return CanDoResult.OUT_OF_ACTIONS
	if owner.is_overheated():
		return CanDoResult.OVERHEATED #abs(distance) <= 1
	
	# distance is already signed
	var forward_data = Global.battle_stage.get_forward_data(owner.get_spot(), false, distance)
	if forward_data is Mech:
		return CanDoResult.MECH_IN_SPOT
	if forward_data is BattleStage.TileOutOfBounds:
		return CanDoResult.EDGE_OF_ARENA
	return CanDoResult.CAN_DO
