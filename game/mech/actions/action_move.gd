extends Action
class_name ActionMove



var config : LegConfig
var distance : int

func do():
	# TODO fancier: if distance in config is > 1, get a selection for how far to go
	owner.move(distance)
