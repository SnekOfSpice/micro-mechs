extends Node2D
class_name BattleStage


var mech1 : Mech
var mech2 : Mech
var commands_this_turn := []
var commands_begun_this_turn := []


func _ready() -> void:
	CommandHandler.command_executed.connect(_on_command_executed)
	CommandHandler.command_executing.connect(_on_command_executing)
	var config := ResourceLoader.load("user://mech_config.tres")
	mech1 = preload("res://mech.tscn").instantiate()
	%BattleLine.add_child(mech1)
	mech1.config = config
	
	mech2 = preload("res://mech.tscn").instantiate()
	%BattleLine.add_child(mech2)
	mech2.config = MechConfig.get_randomized()
	
	var agent := MechAgent.new()
	mech2.add_child(agent)
	
	mech1.position.x = 0
	mech2.position.x = 1 * Mech.WIDTH
	
	Global.player_mech = mech1
	Global.npc_mech = mech2
	Global.battle_stage = self
	
	EventBus.mech_died.connect(_on_mech_died)
	
	_begin_battle()
	#mech1.mech_loaded.connect(_decrement_blocker, CONNECT_ONE_SHOT)
	#mech2.mech_loaded.connect(_decrement_blocker, CONNECT_ONE_SHOT)
	
	await get_tree().process_frame
	%PlayerHUD.register_mechs_to_track(mech1, mech2)

func _process(delta: float) -> void:
	_update_flips()

var blockers := 1
func _decrement_blocker():
	blockers -= 1
	if blockers <= 0:
		_begin_battle()

func _begin_battle():
	_update_flips()
	
	await get_tree().process_frame
	mech1.initialize_combat_stats()
	mech2.initialize_combat_stats()
	
	%PlayerHUD.populate_player_actions(mech1.get_action_list())
	Global.active_mech = mech1
	PhaseManager.begin_match()


func _update_flips():
	mech1.set_flip(mech1.global_position.x > mech2.global_position.x)
	mech2.set_flip(mech2.global_position.x > mech1.global_position.x)
#
#
#func move_mech(mech : Mech, distance : int):
	#var mech_index := mech.get_parent().get_index()
	#move_mech_to(mech, mech_index + distance)
#
#
#func move_mech_to(mech : Mech, slot_index : int):
	#mech.reparent(get_slot(slot_index))
	#mech.position = get_slot_position(slot_index)
#
#func get_slot(slot_index : int) -> TextureRect:
	#if slot_index < 0 or slot_index >= %MechSlots.get_child_count():
		#push_warning("tried to get slot outside of range")
		#slot_index = clampi(slot_index, 0, %MechSlots.get_child_count() - 1)
	#
	#var slot : TextureRect = %MechSlots.get_child(slot_index)
	#return slot
#
#
#func get_slot_position(slot_index : int) -> Vector2:
	#var slot := get_slot(slot_index)
	#
	#var origin := slot.global_position
	#
	#origin.x += slot.texture.get_size().x * 0.5
	#origin.y = slot.texture.get_height()
	#return origin
	#



func do_attack(attacking_mech : Mech, weapon_index : int):
	print("pew pew")

func command_do_attack(attacking_mech : Mech, weapon_index : int):
	var c := CommandDoAttack.new()
	c.attacker = attacking_mech
	c.target = Global.get_other_mech(attacking_mech)
	c.weapon_index = weapon_index
	CommandHandler.add_command(c)


func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://game/main_menu/main_menu.tscn")


func _on_command_executing(command : Command):
	commands_begun_this_turn.append(command)
	EventBus.commands_begun_this_turn_changed.emit()
func _on_command_executed(command : Command):
	commands_this_turn.append(command)
	print(commands_this_turn)
	if commands_this_turn.size() >= Global.active_mech.combat_stats.actions_left:
		PhaseManager.advance_phase()
	EventBus.commands_this_turn_changed.emit()


func hide_range():
	%Highlight.hide()

func highlight_range(range : Vector2):
	#if range == Vector2.ZERO:
		#%Highlight.hide()
		#return
	if range.x > range.y:
		var a := range.x
		range.x = range.y
		range.y = a
	print(range)
	%Highlight.show()
	%Highlight.global_position = %BattleLine.global_position
	#%Highlight.position.x += (range.x * Mech.WIDTH) - Mech.HALF_WIDTH
	%Highlight.points = PackedVector2Array([
		Vector2(range.x * Mech.WIDTH - Mech.HALF_WIDTH, 0),
		Vector2(range.y * Mech.WIDTH + Mech.HALF_WIDTH, 0),
	])
	print(%Highlight.points)


func _on_mech_died(mech : Mech):
	pass
