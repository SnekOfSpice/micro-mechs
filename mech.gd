@tool
extends Node3D
class_name Mech


const WIDTH := 40
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
	get():
		# mechs get positioned along the z axis with higher z values being further right
		# on the battle field to make math easier
		# however this means that once in game, positive z is forward
		# and since default forward is negative z, the flipped logic is a bit backwards
		var absolute_rotation : float = abs(rotation_degrees.y)
		if absolute_rotation > 175 and absolute_rotation < 185:
			return false
		return true


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
	
	var stats = CombatStats.new()
	for thing in ["health", "energy", "heat", "bullets", "rockets"]:
		var max_name := "%s_max" % thing
		var torso_value = torso_config.get(max_name)
		stats.set(thing, torso_value)
		stats.set(max_name, torso_value)
	stats.health += leg_config.health
	stats.health_max += leg_config.health
	
	if agent:
		stats.health = 2
		stats.health_max = 2
	
	stats.heat = 0
	
	combat_stats = stats
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
	var weapon_path := "res://parts/weapons/scenes/%s.tscn" % weapon_id
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
	var leg_path := "res://parts/legs/scenes/%s.tscn" % tech_id
	
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
	print("TODO leg height")
	#if leg_front:
		#var leg_sprite : Sprite2D = leg_front.get_child(0)
		#leg_height += leg_sprite.texture.get_size().y
		#leg_height += leg_sprite.position.y
	
	var pivot_offset : float = _torso.find_child("LegTransformFront").position.y
	
	return leg_height + pivot_offset# + _torso.texture.get_size().y * 0.5




func set_flip(flipped : bool):
	# unneeded in 3d
	return
	_torso.set_flipped(flipped)
	#%TorsoPivot.scale.x = -1 if flipped else 1
	for pivot : Pivot in %LegPivots.get_children():
		pivot.set_flipped(flipped)
	for pivot : Pivot in %WeaponPivots.get_children():
		pivot.set_flipped(flipped)
	#%WeaponPivots.scale.x = -1 if flipped else 1


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	if Global.battle_stage:
		Global.battle_stage.register(self)


func _get_leg_config() -> LegConfig:
	if not _leg_config:
		_leg_config = %LegPivots.get_child(0).config
	return _leg_config


func is_in_front_of_other_mech() -> bool:
	
	if Global.battle_stage.get_forward_data(get_spot(), flipped, 1) is Mech:
		return true
	return false
	


func get_action_list() -> Array[Action]:
	var result : Array[Action] = []
	
	var cd_action := ActionCoolDown.new()
	cd_action.owner = self
	result.append(cd_action)
	var stomp_action := ActionStomp.new()
	stomp_action.owner = self
	result.append(stomp_action)
	var flip_action := ActionFlip.new()
	flip_action.owner = self
	result.append(flip_action)
	
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
	return index == Global.battle_stage.get_spot(self)


func get_distance_to_spot(spot : int) -> int:
	return abs(get_spot() - spot)



func is_in_range(r : Vector2i) -> bool:
	var lower := mini(r.x, r.y)
	var upper := maxi(r.x, r.y)
	var spot := get_spot()
	return spot >= lower and spot <= upper
	#var index_range := r * WIDTH
	#
	#return position.x >= (index_range.x - 0.001) and position.x <= (index_range.y + 0.001)


func get_spot() -> int:
	if Global.battle_stage:
		return Global.battle_stage.get_spot(self)
	return int(position.z / float(WIDTH))


func is_overheated():
	return combat_stats.heat > combat_stats.heat_max


var weapon_configs_used_this_turn := []


func can_use_weapon(weapon_config : WeaponConfig) -> Action.CanDoResult:
	if not combat_stats:
		return Action.CanDoResult.NO_COMBAT_STATS_ERR
	
	if weapon_config in weapon_configs_used_this_turn:
		return Action.CanDoResult.USED_THIS_TURN
	
	if weapon_config.bullet_consumption > combat_stats.bullets:
		return Action.CanDoResult.OUT_OF_BULLETS
	
	if weapon_config.rocket_consumption > combat_stats.rockets:
		return Action.CanDoResult.OUT_OF_ROCKETS
	
	if weapon_config.energy_consumption_self > combat_stats.energy:
		return Action.CanDoResult.OUT_OF_ENERGY
	
	if weapon_config.uses > -1:
		if weapon_config.uses_left == 0:
			return Action.CanDoResult.OUT_OF_USES
	
	var weapon_range := get_weapon_attack_bounds(weapon_config)
	var in_range : bool = Global.battle_stage.is_any_mech_in_range(weapon_range)
	if in_range:
		return Action.CanDoResult.CAN_DO
	else:
		return Action.CanDoResult.OUT_OF_RANGE


func aim_at(target_index : int):
	if get_spot() < target_index and flipped:
		flip()
	elif get_spot() > target_index and not flipped:
		flip()


## returns the range of indices, with origin in the spot of this mech
func get_offset_bounds(bounds : Vector2i) -> Vector2i:
	var adjusted_range : Vector2i = Vector2i(get_spot(), get_spot())
	if flipped:
		adjusted_range -= bounds
	else:
		adjusted_range += bounds
	
	if adjusted_range.x > adjusted_range.y:
		var swap := adjusted_range.x
		adjusted_range.x = adjusted_range.y
		adjusted_range.y = swap
	return adjusted_range


func get_weapon_attack_bounds(weapon_config : WeaponConfig) -> Vector2i:
	return get_offset_bounds(weapon_config.weapon_range)


func is_entirely_on_screen() -> bool:
	for vis : VisibleOnScreenNotifier3D in %VisibleGuarantee.get_children():
		if not vis.is_on_screen():
			return false
	return true


func too_much_dead_space() -> bool:
	for vis : VisibleOnScreenNotifier3D in %DeadSpaceEliminators.get_children():
		if not vis.is_on_screen():
			return false
	return true


func refill_actions(amount := 2):
	Global.battle_stage.commands_begun_this_turn.clear()
	combat_stats.actions_left = amount
	EventBus.request_action_rebuild.emit()


var agent : MechAgent

func is_dead() -> bool:
	return combat_stats.health <= 0


func cool_down():
	var dur : float = _torso.anim("cool_down")
	_reduce_heat_active()
	await get_tree().create_timer(dur).timeout


func stomp():
	var knockback := 1# put into config
	var other_mech = Global.battle_stage.get_forward_data(get_spot(), flipped, knockback)
	if not other_mech is Mech:
		push_warning("Tried to stomp with no mech in front")
		return
	await _torso.stomp_anim()
	var stomp_attack := WeaponConfig.new()
	stomp_attack.damage = _leg_config.stomp_damage
	stomp_attack.knockback = knockback
	other_mech.handle_attacked(stomp_attack)


func move_to_index(index : int, duration : float = 0.0):
	index = clampi(index, 0, BattleStage.ARENA_SIZE_RANGE.y - 1)
	if not Global.battle_stage.is_spot_free(index):
		return
	Global.battle_stage.handle_spot_change(self, get_spot(), index)
	_move(index * WIDTH + HALF_WIDTH, duration)


func _process(delta: float) -> void:
	if not Global.battle_stage:
		$Label3D.hide()
		return
	if agent:
		$Label3D.modulate.a = 0.5
	$Label3D.text = str(
		"Health : ", combat_stats.health,
		"\n",
		Global.battle_stage.commands_begun_this_turn.size(),
		"/",
		combat_stats.actions_left,
		"\n",
		position.z,
		)
	if Global.player_mech == self:
		$Label3D.text += "\nv"

func _move(target_z : float, duration : float):
	var t := create_tween()
	t.tween_property(self, "position:z", target_z, duration)
	await t.finished
	await get_tree().create_timer(1).timeout

func command_cool_down():
	var c = CommandCoolDown.new()
	c.targets = [self]
	CommandHandler.add_command(c)
func command_stomp():
	var c = CommandStomp.new()
	c.targets = [self]
	CommandHandler.add_command(c)

func command_move(distance : int):
	if flipped:
		distance *= -1
	var c = CommandMove.new()
	c.targets = [self]
	c.spots_to_move = distance
	CommandHandler.add_command(c)


func get_weapon(weapon_index : int) -> WeaponPivot:
	return %WeaponPivots.get_child(weapon_index)


func get_weapon_config(weapon_index : int) -> WeaponConfig:
	var weapon : WeaponPivot = get_weapon(weapon_index)
	var weapon_config : WeaponConfig = weapon.config
	return weapon_config


func do_attack(target : Mech, weapon_index : int):
	var weapon : WeaponPivot = get_weapon(weapon_index)
	var weapon_config : WeaponConfig = get_weapon_config(weapon_index)
	weapon_configs_used_this_turn.append(weapon_config)
	
	combat_stats.bullets -= weapon_config.bullet_consumption
	combat_stats.rockets -= weapon_config.rocket_consumption
	combat_stats.energy -= weapon_config.energy_consumption_self
	combat_stats.heat += weapon_config.heat_generation_self
	
	if weapon_config.uses > -1:
		weapon_config.uses_left = max(0, weapon_config.uses_left - 1)
	
	var duration := await weapon.attack_animation(target)
	await get_tree().create_timer(duration).timeout


# usedful for multi projectile
var timestamps := []
func handle_attacked(with : WeaponConfig, timestamp := Time.get_ticks_msec(), impact_position : Vector3 = get_projectile_point()):
	var damage := randi_range(with.damage.x, with.damage.y)
	combat_stats.health -=  damage
	
	Global.battle_stage.add_floating_number(damage, impact_position)
	
	if timestamp in timestamps:
		return
	
	timestamps.append(timestamp)
	combat_stats.energy -= with.energy_consumption_target
	combat_stats.heat += with.heat_generation_target
	
	if with.knockback > 0:
		var knockback_direction : int = 1 if flipped else -1
		var target := get_spot() + with.knockback * knockback_direction
		move_to_index(target * with.knockback, 0.2)


func _on_combat_stats_changed():
	if not combat_stats:
		return
	if combat_stats.health <= 0:
		EventBus.mech_died.emit(self)


func reduce_heat_passive():
	combat_stats.heat -= _torso.config.cooldown_passive
	combat_stats.heat = max(combat_stats.heat, 0)

func _reduce_heat_active():
	combat_stats.heat -= _torso.config.cooldown_active
	combat_stats.heat = max(combat_stats.heat, 0)

func generate_energy():
	combat_stats.energy += _torso.config.energy_generation
	combat_stats.energy = clamp(combat_stats.energy, 0, combat_stats.energy_max)
	
	
	
func get_projectile_point() -> Vector3:
	var base := _torso.global_position
	var torso_size := _torso.get_size()
	#torso_size -= torso_size * 0.5
	torso_size *= 0.75
	#
	return base + Vector3(
		randf_range(-torso_size.x, torso_size.x),
		randf_range(-torso_size.y, torso_size.y),
		randf_range(-torso_size.z, torso_size.z),
	)


func command_flip():
	var c = CommandFlip.new()
	c.targets = [self]
	CommandHandler.add_command(c)


func flip():
	rotate_y(deg_to_rad(180))
	rotation_degrees.y = int(rotation_degrees.y) % 360


func is_pointed_at_enemy() -> bool:
	if self == Global.player_mech:
		var lower : int
		var upper : int
		if flipped:
			lower = 0
			upper = get_spot() - 1
		else:
			lower = get_spot() + 1
			upper = Global.battle_stage.get_arena_size() - 1
		return Global.battle_stage.is_any_mech_in_range(Vector2(lower, upper))
	else:
		var player_spot : int = Global.player_mech.get_spot()
		var spot := get_spot()
		if flipped:
			return spot > player_spot
		else:
			return spot < player_spot
