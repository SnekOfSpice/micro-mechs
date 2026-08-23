@tool
extends Node2D
class_name Mech


const WIDTH := 128
const HALF_WIDTH : int = int(WIDTH * 0.5)
var combat_stats : CombatStats:
	set(value):
		combat_stats = value
		if combat_stats:
			if not combat_stats.changed.is_connected(_on_combat_stats_changed):
				combat_stats.changed.connect(_on_combat_stats_changed)
			combat_stats.changed.emit()


@export var config : MechConfig:
	set(value):
		config = value
		if config:
			if not config.changed.is_connected(load_mech):
				config.changed.connect(load_mech)
			config.changed.emit()

@export var flipped: bool:
	set(value):
		flipped = value
		if is_inside_tree():
			set_flip(flipped)

var _torso : Torso:
	get():
		if not find_child("TorsoPivot"):
			return _torso
		if not _torso and %TorsoPivot.get_child(0) is Torso:
			_torso = %TorsoPivot.get_child(0)
		config.weapon_list.resize(_torso.weapon_count)
		return _torso


# TODO refactor this to be part of torso config
var weapon_capacity : int:
	get():
		if not _torso:
			return 0
		return _torso.weapon_count


func load_mech():
	if not config:
		return
	if not is_inside_tree():
		return
	
	# load order is important
	_load_torso(config.torso_id)
	#await get_tree().process_frame
	_load_legs(config.leg_id)
	#await get_tree().process_frame
	_load_weapons(config.weapon_list)
	
	%TorsoPivot.position.y = -_get_mech_height()
	
	mech_loaded.emit()


signal mech_loaded()


func initialize_combat_stats() -> CombatStats:
	if combat_stats:
		combat_stats.unreference()
		combat_stats = null
	
	var torso_config : TorsoConfig = _torso.config
	var leg_config : LegConfig = _get_leg_config()
	
	combat_stats = CombatStats.new()
	for thing in ["health", "energy", "heat", "bullets", "rockets"]:
		var max_name := "%s_max" % thing
		var torso_value = torso_config.get(max_name)
		combat_stats.set(thing, torso_value)
		combat_stats.set(max_name, torso_value)
	combat_stats.health += leg_config.health
	combat_stats.health_max += leg_config.health
	combat_stats.heat = 0
	EventBus.combat_stats_changed.emit(self)
	combat_stats.changed.connect(EventBus.combat_stats_changed.emit.bind(self))
	
	return combat_stats



func _load_weapons(weapon_id_list : PackedStringArray):
	if not find_child("WeaponPivots"):
		return
	for child in %WeaponPivots.get_children():
		child.free()
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
	
	var front : LegPivot = load(leg_path).instantiate()
	var back : LegPivot = load(leg_path).instantiate()
	
	for child in %LegPivots.get_children():
		child.queue_free()
	
	_leg_config = front.config
	%LegPivots.add_child(front)
	front.owner = get_tree().edited_scene_root
	%LegPivots.add_child(back)
	back.owner = get_tree().edited_scene_root
	
	_torso.hook_up_legs(front, back)

var _leg_config : LegConfig


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




func set_flip(flipped : bool):
	_torso.set_flipped(flipped)
	#%TorsoPivot.scale.x = -1 if flipped else 1
	for pivot : Pivot in %LegPivots.get_children():
		pivot.set_flipped(flipped)
	for pivot : Pivot in %WeaponPivots.get_children():
		pivot.set_flipped(flipped)
	#%WeaponPivots.scale.x = -1 if flipped else 1



func _get_leg_config() -> LegConfig:
	if not _leg_config:
		_leg_config = %LegPivots.get_child(0).config
	return _leg_config


func get_action_list() -> Array[Action]:
	var result : Array[Action] = []
	
	var cd_action := ActionCoolDown.new()
	cd_action.owner = self
	result.append(cd_action)
	
	var leg_config : LegConfig = _get_leg_config()
	for i in range(-leg_config.movement, leg_config.movement + 1):
		if i == 0:
			continue
		var move_action := ActionMove.new()
		move_action.owner = self
		move_action.config = leg_config
		move_action.distance = i
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





func is_in_spot(index : int) -> bool:
	var index_position := index * WIDTH
	var distance : float = position.x - index_position
	return abs(distance) < 0.001



func is_in_range(r : Vector2) -> bool:
	var index_range := r * WIDTH
	
	return position.x >= (index_range.x - 0.001) and position.x <= (index_range.y + 0.001)


func get_spot() -> int:
	return int(position.x / float(WIDTH))


func is_overheated():
	return combat_stats.heat > combat_stats.heat_max


func can_use_weapon(weapon_config : WeaponConfig) -> bool:
	if not combat_stats:
		return false
	
	if weapon_config.bullet_consumption > combat_stats.bullets:
		return false
	
	if weapon_config.rocket_consumption > combat_stats.rockets:
		return false
	
	if weapon_config.energy_consumption_self > combat_stats.energy:
		return false
	
	var adjusted_range : Vector2 = weapon_config.weapon_range
	adjusted_range.x += get_spot()
	adjusted_range.y += get_spot()
	return Global.get_other_mech(self).is_in_range(adjusted_range)
	


func is_entirely_on_screen() -> bool:
	for vis : VisibleOnScreenNotifier2D in %VisibleGuarantee.get_children():
		if not vis.is_on_screen():
			return false
	return true


func too_much_dead_space() -> bool:
	for vis : VisibleOnScreenNotifier2D in %DeadSpaceEliminators.get_children():
		if not vis.is_on_screen():
			return false
	return true


#func decrement_actions():
	#var prev := combat_stats.actions_left
	#combat_stats.actions_left -= 1
	#if combat_stats.actions_left <= 0 and prev > 0:
		#PhaseManager.advance_phase()

func refill_actions(amount := 2):
	combat_stats.actions_left = amount


var agent : MechAgent


func cool_down():
	var dur : float = _torso.anim("cool_down")
	_reduce_heat_active()
	await get_tree().create_timer(dur).timeout


func move(target_position : Vector2, duration : float):
	var t := create_tween()
	t.tween_property(self, "position", target_position, duration)
	await t.finished

func command_cool_down():
	var c = CommandCoolDown.new()
	c.targets = [self]
	CommandHandler.add_command(c)

func command_move(distance : int):
	var target_position := position.x + distance * WIDTH
	var c = CommandMove.new()
	c.targets = [self]
	c.target_position = Vector2(target_position, position.y)
	CommandHandler.add_command(c)


func get_weapon_config(weapon_index : int) -> WeaponConfig:
	var weapon : WeaponPivot = %WeaponPivots.get_child(weapon_index)
	var weapon_config : WeaponConfig = weapon.config
	return weapon_config


func do_attack(target : Mech, weapon_index : int):
	var weapon : WeaponPivot = %WeaponPivots.get_child(weapon_index)
	var weapon_config : WeaponConfig = weapon.config
	
	combat_stats.bullets -= weapon_config.bullet_consumption
	combat_stats.rockets -= weapon_config.rocket_consumption
	combat_stats.energy -= weapon_config.energy_consumption_self
	combat_stats.heat += weapon_config.heat_generation_self
	
	var duration := weapon.attack_animation(Global.get_other_mech(self))
	await get_tree().create_timer(duration).timeout

func handle_attacked(with : WeaponConfig):
	var damage := randi_range(with.damage.x, with.damage.y)
	combat_stats.health -=  damage
	combat_stats.energy -= with.energy_consumption_target
	combat_stats.heat -= with.heat_generation_target
	
	var knockback_direction : int = -1 if flipped else 1
	var target := get_spot() + with.knockback * knockback_direction
	move(Vector2(target * WIDTH, position.y), 0.2)


func _on_combat_stats_changed():
	if not combat_stats:
		return
	if combat_stats.health <= 0:
		print("DIe")


func reduce_heat_passive():
	combat_stats.heat -= _torso.config.cooldown_passive
	combat_stats.heat = max(combat_stats.heat, 0)

func _reduce_heat_active():
	combat_stats.heat -= _torso.config.cooldown_active
	combat_stats.heat = max(combat_stats.heat, 0)

func generate_energy():
	combat_stats.energy += _torso.config.energy_generation
	combat_stats.energy = clamp(combat_stats.energy, 0, combat_stats.energy_max)
	
	
	
