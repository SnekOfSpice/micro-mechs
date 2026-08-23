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
	
	disabled = not action.can_do()



func _on_pressed() -> void:
	_on_mouse_exited()
	if CommandHandler.awaiting_execution:
		return
	action.do()
	EventBus.request_action_rebuild.emit()


func _on_mouse_entered() -> void:
	#EventBus.request_action_rebuild.emit()
	var mech_spot := action.owner.get_spot()
	if action is ActionMove:
		Global.battle_stage.highlight_range(
			Vector2(
				mech_spot + action.distance,
				mech_spot + action.distance,
			)
		)
	if action is ActionWeapon:
		var weapon_range : Vector2 = action.config.weapon_range
		Global.battle_stage.highlight_range(
			Vector2(
				mech_spot + weapon_range.x,
				mech_spot + weapon_range.y,
			)
		)
		Global.hud.visualize_weapon(action.config, action.owner)

func _on_mouse_exited() -> void:
	Global.battle_stage.hide_range()
	Global.hud.hide_weapon_visualizer()
