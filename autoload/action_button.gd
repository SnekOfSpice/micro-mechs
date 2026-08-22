extends Button
class_name ActionButton


var action : Action:
	set(value):
		action = value
		_rebuild()


func _rebuild():
	if action is ActionCoolDown:
		text = "cool down"
	elif action is ActionMove:
		text = "move %s" % action.distance
	elif action is ActionWeapon:
		text = "attack"
	
	disabled = _is_action_prohibited()

func _is_action_prohibited() -> bool:
	return false


func _on_pressed() -> void:
	action.do()
	_rebuild()
