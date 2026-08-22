extends Node2D
class_name BattleStage


func _ready() -> void:
	var mech1 := preload("res://mech.tscn").instantiate()
	add_child(mech1)
	move_mech_to(mech1, 1)
	var mech2 := preload("res://mech.tscn").instantiate()
	add_child(mech2)
	move_mech_to(mech2, 9)



func move_mech(mech : Mech, distance : int):
	var mech_index := mech.get_parent().get_index()
	move_mech_to(mech, mech_index + distance)


func move_mech_to(mech : Mech, slot_index : int):
	mech.reparent(get_slot(slot_index))
	mech.position = get_slot_position(slot_index)

func get_slot(slot_index : int) -> TextureRect:
	if slot_index < 0 or slot_index >= %MechSlots.get_child_count():
		push_warning("tried to get slot outside of range")
		slot_index = clampi(slot_index, 0, %MechSlots.get_child_count() - 1)
	
	var slot : TextureRect = %MechSlots.get_child(slot_index)
	return slot


func get_slot_position(slot_index : int) -> Vector2:
	var slot := get_slot(slot_index)
	
	var origin := slot.global_position
	
	origin.x += slot.texture.get_size().x * 0.5
	origin.y = slot.texture.get_height()
	return origin
	
