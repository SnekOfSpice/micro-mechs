@tool
extends Node2D


@export var weapon_list : PackedStringArray = []:
	set(value):
		weapon_list = value
		load_weapons(weapon_list)

@export var leg_id := "":
	set(value):
		leg_id = value
		load_legs(leg_id)


func load_weapons(weapon_id_list : PackedStringArray):
	var i := 0
	while i < weapon_id_list.size():
		load_weapon(weapon_id_list[i], i)
		i += 1


func load_weapon(weapon_id : String, weapon_index : int):
	var weapon_path := "res://parts/weapons/%s.tscn" % weapon_id
	if not ResourceLoader.exists(weapon_path):
		print("no weapon")
		return
	print("making weapon")
	var weapon : Pivot = load(weapon_path).instantiate()
	
	%Torso.free_weapon(weapon_index)
	
	%WeaponPivots.add_child(weapon)
	weapon.owner = get_tree().edited_scene_root
	
	%Torso.set_weapon(weapon_index, weapon)

func load_legs(tech_id : String) -> void:
	var front_path := "res://parts/legs/%s_front.tscn" % tech_id
	var back_path := "res://parts/legs/%s_back.tscn" % tech_id
	
	if not (ResourceLoader.exists(front_path) and ResourceLoader.exists(back_path)):
		return
	
	var front : Pivot = load(front_path).instantiate()
	var back : Pivot = load(back_path).instantiate()
	
	for child in %LegPivots.get_children():
		child.queue_free()
	
	%LegPivots.add_child(front)
	front.owner = get_tree().edited_scene_root
	%LegPivots.add_child(back)
	back.owner = get_tree().edited_scene_root
	
	%Torso.hook_up_legs(front, back)
	
	
