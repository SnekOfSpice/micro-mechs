extends Action
class_name ActionMove



var config : LegConfig
var distance : int

func do():
	# TODO fancier: if distance in config is > 1, get a selection for how far to go
	owner.command_move(distance)

func can_do() -> bool:
	if owner.is_overheated():
		return abs(distance) <= 1
	var other : Mech = Global.get_other_mech(owner)
	var query_distance := owner.get_spot() + distance
	var in_spot := other.is_in_spot(query_distance)
	if in_spot:
		return false
	return true
