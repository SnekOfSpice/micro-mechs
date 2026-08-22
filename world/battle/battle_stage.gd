extends Node2D
class_name BattleStage


var mech1 : Mech
var mech2 : Mech


func _ready() -> void:
	var config := ResourceLoader.load("user://mech_config.tres")
	mech1 = Mech.make(config)
	%BattleLine.add_child(mech1)
	
	
	var evil_config := MechConfig.new()
	evil_config.leg_id = "leg_1"
	evil_config.torso_id = "torso_1"
	evil_config.weapon_list = PackedStringArray(["cannon_1", "cannon_2"])
	mech2 = Mech.make(evil_config)
	%BattleLine.add_child(mech2)
	
	
	
	mech1.position.x = 0
	mech2.position.x = 13 * Mech.WIDTH
	
	Global.player_mech = mech1
	Global.npc_mech = mech2
	Global.battle_stage = self
	
	_begin_battle()
	#mech1.mech_loaded.connect(_decrement_blocker, CONNECT_ONE_SHOT)
	#mech2.mech_loaded.connect(_decrement_blocker, CONNECT_ONE_SHOT)
	
	await get_tree().process_frame
	%PlayerHUD.register_mechs_to_track(mech1, mech2)
	

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


func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://game/main_menu/main_menu.tscn")
