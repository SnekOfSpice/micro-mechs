@tool
extends Node2D


@export var torso_id := "":
	set(value):
		torso_id = value
		load_mech()

@export var weapon_list : PackedStringArray = []:
	set(value):
		weapon_list = value
		load_mech()

@export var leg_id := "":
	set(value):
		leg_id = value
		load_mech()


var _torso : Torso:
	get():
		if not _torso and %TorsoPivot.get_child(0) is Torso:
			_torso = %TorsoPivot.get_child(0)
		return _torso


func load_mech():
	load_torso(torso_id)
	await get_tree().process_frame
	load_legs(leg_id)
	await get_tree().process_frame
	load_weapons(weapon_list)
	
	%TorsoPivot.position.y = -_get_mech_height()


func load_weapons(weapon_id_list : PackedStringArray):
	if not find_child("WeaponPivots"):
		return
	for child in %WeaponPivots.get_children():
		child.queue_free()
	var i := 0
	while i < weapon_id_list.size():
		load_weapon(weapon_id_list[i], i)
		i += 1


func load_weapon(weapon_id : String, weapon_index : int):
	if not _torso:
		return
	var weapon_path := "res://parts/weapons/%s.tscn" % weapon_id
	if not ResourceLoader.exists(weapon_path):
		print("no weapon")
		return
	print("making weapon")
	var weapon : Pivot = load(weapon_path).instantiate()
	
	_torso.free_weapon(weapon_index)
	
	%WeaponPivots.add_child(weapon)
	weapon.owner = get_tree().edited_scene_root
	
	_torso.set_weapon(weapon_index, weapon)

func load_legs(tech_id : String) -> void:
	if not _torso:
		return
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
	
	_torso.hook_up_legs(front, back)
	

func load_torso(tech_id : String):
	if not find_child("TorsoPivot"):
		return
	
	var path := "res://parts/torsos/%s.tscn" % tech_id
	
	if not ResourceLoader.exists(path):
		print("no torso")
		return
	print("torso")
	
	for child in %TorsoPivot.get_children():
		child.queue_free()
	
	var torso : Torso = load(path).instantiate()
	%TorsoPivot.add_child(torso)
	torso.owner = get_tree().edited_scene_root
	
	_torso = torso




func _get_mech_height() -> float:
	if not _torso:
		return 0
	var leg_height : float = 0
	var leg_front : Pivot = %LegPivots.get_child(0)
	if not leg_front:
		return 0
	if leg_front:
		var leg_sprite : Sprite2D = leg_front.get_child(0)
		leg_height += leg_sprite.texture.get_size().y
		leg_height -= leg_sprite.position.y
	
	var pivot_offset : float = _torso.find_child("LegTransformFront").position.y
	
	return leg_height + pivot_offset# + _torso.texture.get_size().y * 0.5
