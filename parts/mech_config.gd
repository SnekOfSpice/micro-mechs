@tool
extends Resource
class_name MechConfig


@export var torso_id := "":
	set(new_value):
		if torso_id != new_value:
			torso_id = new_value
			emit_changed()


@export var leg_id := "":
	set(new_value):
		if leg_id != new_value:
			leg_id = new_value
			emit_changed()


@export var weapon_list : PackedStringArray = []:
	set(new_value):
		if weapon_list != new_value:
			weapon_list = new_value
			emit_changed()


func set_weapon(index : int, weapon_id : String):
	if index >= weapon_list.size():
		weapon_list.resize(index + 1)
	weapon_list[index] = weapon_id
	emit_changed()


static func get_randomized() -> MechConfig:
	randomize()
	var config := MechConfig.new()
	config.leg_id = ["leg_1", "leg_2"].pick_random()
	config.torso_id = ["torso_1", "torso_2"].pick_random()
	var quick_torso : Torso = load("res://parts/torsos/%s.tscn" % config.torso_id).instantiate()
	var weapon_count : int = quick_torso.weapon_count
	quick_torso.queue_free()
	var weapons : Array = Global.get_weapon_configs()
	for count in weapon_count:
		config.weapon_list.append(weapons.pick_random())
	return config
