extends Button
class_name ActionButton


var action : Action:
	set(value):
		action = value
		_rebuild()


func _ready() -> void:
	EventBus.request_action_rebuild.connect(_rebuild)


func _rebuild():
	if action is ActionCoolDown:
		text = "cool down"
	elif action is ActionMove:
		text = "move %s" % action.distance
	elif action is ActionWeapon:
		text = "attack"
	
	disabled = not action.can_do()



func _on_pressed() -> void:
	action.do()
	EventBus.request_action_rebuild.emit()
