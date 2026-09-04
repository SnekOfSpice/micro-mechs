extends Button
class_name ActionButton


var action : Action:
	set(value):
		action = value
		_rebuild()


func _ready() -> void:
	EventBus.request_action_rebuild.connect(_rebuild)
	CommandHandler.command_executed.connect(func(_c): _rebuild())




func is_mouse_in() -> bool:
	if not get_viewport():
		return false
	var mouse_pos := get_local_mouse_position()
	return mouse_pos.x >= 0 and mouse_pos.y >= 0 and mouse_pos.x <= size.x and mouse_pos.y <= size.y


func _rebuild():
	if is_mouse_in():
		_on_mouse_entered()
	if action is ActionCoolDown:
		text = "cool down"
	elif action is ActionMove:
		text = "move %s" % action.distance
	elif action is ActionWeapon:
		text = "attack"
	elif action is ActionStomp:
		text = "stomp"
	elif action is ActionFlip:
		text = "flip"
	
	var can_do : Action.CanDoResult = action.can_do()
	if can_do == Action.CanDoResult.CAN_DO:
		disabled = false
		$Label.text = ""
	else:
		$Label.text = Action.CanDoResult.keys()[can_do]
		disabled = true
	
	



func _on_pressed() -> void:
	_on_mouse_exited()
	if CommandHandler.awaiting_execution:
		return
	action.do()
	Global.player_mech.combat_stats.actions_left -= 1
	await get_tree().process_frame
	EventBus.request_action_rebuild.emit()


func _on_mouse_entered() -> void:
	Global.visualize_action_range(action, Global.player_mech)


func _on_mouse_exited() -> void:
	Global.battle_stage.hide_range(Global.player_mech)
	Global.hud.hide_weapon_visualizer()
