extends Button
class_name ActionButton


var action : Action:
	set(value):
		action = value
		_rebuild()


func _ready() -> void:
	EventBus.request_action_rebuild.connect(_rebuild)
	CommandHandler.command_executed.connect(func(_c): _rebuild())


func _rebuild():
	if action is ActionCoolDown:
		text = "cool down"
	elif action is ActionMove:
		text = "move %s" % action.distance
	elif action is ActionWeapon:
		text = "attack"
	
	disabled = not action.can_do()



func _on_pressed() -> void:
	if CommandHandler.awaiting_execution:
		return
	#var actions_left := action.owner.combat_stats.actions_left
	#if CommandHandler.command_queue.size() >= actions_left - (1 if CommandHandler.awaiting_execution else 0):
		#return
	print()
	action.do()
	EventBus.request_action_rebuild.emit()


func _on_mouse_entered() -> void:
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

func _on_mouse_exited() -> void:
	Global.battle_stage.hide_range()
