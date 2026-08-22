@tool
extends Node2D
class_name Mech


const WIDTH := 128
var combat_stats : CombatStats


@export var config : MechConfig:
	set(value):
		config = value
		if config:
			config.changed.connect(load_mech)
			config.changed.emit()

@export var flipped: bool:
	set(value):
		flipped = value
		set_flip(flipped)

var _torso : Torso:
	get():
		if not _torso and %TorsoPivot.get_child(0) is Torso:
			_torso = %TorsoPivot.get_child(0)
		return _torso

func load_mech():
	if not config:
		return
	if not is_inside_tree():
		return
	
	# load order is important
	_load_torso(config.torso_id)
	await get_tree().process_frame
	_load_legs(config.leg_id)
	await get_tree().process_frame
	_load_weapons(config.weapon_list)
	
	%TorsoPivot.position.y = -_get_mech_height()



func _initialize_combat_stats():
	pass

func _load_weapons(weapon_id_list : PackedStringArray):
	if not find_child("WeaponPivots"):
		return
	for child in %WeaponPivots.get_children():
		child.queue_free()
	var i := 0
	while i < weapon_id_list.size():
		_load_weapon(weapon_id_list[i], i)
		i += 1


func _load_weapon(weapon_id : String, weapon_index : int):
	if not _torso:
		return
	var weapon_path := "res://parts/weapons/%s.tscn" % weapon_id
	if not ResourceLoader.exists(weapon_path):
		return
	var weapon : Pivot = load(weapon_path).instantiate()
	
	_torso.free_weapon(weapon_index)
	
	%WeaponPivots.add_child(weapon)
	weapon.owner = get_tree().edited_scene_root
	
	_torso.set_weapon(weapon_index, weapon)


func _load_legs(tech_id : String) -> void:
	if not find_child("LegPivots"):
		return
	if not _torso:
		return
	var leg_path := "res://parts/legs/%s.tscn" % tech_id
	
	if not ResourceLoader.exists(leg_path):
		return
	
	var front : Pivot = load(leg_path).instantiate()
	var back : Pivot = load(leg_path).instantiate()
	
	for child in %LegPivots.get_children():
		child.queue_free()
	
	%LegPivots.add_child(front)
	front.owner = get_tree().edited_scene_root
	%LegPivots.add_child(back)
	back.owner = get_tree().edited_scene_root
	
	_torso.hook_up_legs(front, back)
	

func _load_torso(tech_id : String):
	if not find_child("TorsoPivot"):
		return
	
	var path := "res://parts/torsos/%s.tscn" % tech_id
	
	if not ResourceLoader.exists(path):
		return
	
	for child in %TorsoPivot.get_children():
		child.queue_free()
	
	var torso : Torso = load(path).instantiate()
	%TorsoPivot.add_child(torso)
	torso.owner = get_tree().edited_scene_root
	
	_torso = torso


func _get_mech_height() -> float:
	if not find_child("LegPivots"):
		return 0
	if not _torso:
		return 0
	var leg_height : float = 0
	var leg_front : Pivot = %LegPivots.get_child(0)
	if not leg_front:
		return 0
	if leg_front:
		var leg_sprite : Sprite2D = leg_front.get_child(0)
		leg_height += leg_sprite.texture.get_size().y
		leg_height += leg_sprite.position.y
	
	var pivot_offset : float = _torso.find_child("LegTransformFront").position.y
	
	return leg_height + pivot_offset# + _torso.texture.get_size().y * 0.5


static func make(from_config : MechConfig) -> Mech:
	var mech := preload("res://mech.tscn").instantiate()
	mech.config = from_config
	return mech


func set_flip(flipped : bool):
	_torso.set_flipped(flipped)
	#%TorsoPivot.scale.x = -1 if flipped else 1
	for pivot : Pivot in %LegPivots.get_children():
		pivot.set_flipped(flipped)
	for pivot : Pivot in %WeaponPivots.get_children():
		pivot.set_flipped(flipped)
	#%WeaponPivots.scale.x = -1 if flipped else 1


func get_action_list() -> Array[Action]:
	var result : Array[Action] = []
	
	var cd_action := ActionCoolDown.new()
	cd_action.owner = self
	result.append(cd_action)
	
	var leg_config : LegConfig = %LegPivots.get_child(0).config
	for i in range(1, leg_config.movement + 1):
		for factor in [1, -1]:
			var move_action := ActionMove.new()
			move_action.owner = self
			move_action.config = leg_config
			move_action.distance = i * factor
			result.append(move_action)
	
	var i := 0
	for weapon : WeaponPivot in %WeaponPivots.get_children():
		var weapon_action := ActionWeapon.new()
		weapon_action.owner = self
		weapon_action.weapon_index = i
		weapon_action.config = weapon.config
		result.append(weapon_action)
		i += 1
	
	return result


func cool_down():
	print("TODO REDUCE HEAT")


func move(distance : int):
	position.x += distance * WIDTH
