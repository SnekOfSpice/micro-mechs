@tool
class_name WeaponPivot
extends Pivot


@export var config := WeaponConfig.new()


var _muzzle_marker : Marker3D:
	get():
		if not _muzzle_marker:
			for child in get_children():
				if child is Marker3D:
					_muzzle_marker = child
					break
		return _muzzle_marker
var _muzzle_position: Vector3:
	get():
		if not _muzzle_marker:
			return global_position
		return _muzzle_marker.global_position

func _ready() -> void:
	if Engine.is_editor_hint():
		if not config:
			config = WeaponConfig.new()


func attack_animation(attack_target : Mech, attacker : Mech) -> float:
	var target_position : Vector3 = attack_target.get_projectile_point()
	
	#var factor := -1 if _sprite.flip_h else 1
	_mesh.position.z = -.4# * factor
	var recoil_duration := 0.1
	var attack_timestamp := Time.get_ticks_msec()
	
	var distance_to_target := global_position.distance_to(target_position)
		# TODO put appearence into config
	var projectile_flight_duration = distance_to_target / 750.0
	
	for i in config.projectiles:
		var t := create_tween()
		t.tween_property(_mesh, "position:z", 0, recoil_duration)
	
		var projectile := MeshInstance3D.new()
		projectile.mesh = SphereMesh.new()
		var mat_color := Color.WHITE
		match config.damage_type:
			WeaponConfig.DamageType.Kinetic:
				mat_color = Color.YELLOW
			WeaponConfig.DamageType.Electric:
				mat_color = Color.AQUA
			WeaponConfig.DamageType.Explosive:
				mat_color = Color.CRIMSON
		var mat := StandardMaterial3D.new()
		mat.albedo_color = mat_color
		projectile.material_override = mat
		
		projectile.mesh.radius = config.damage.x * 2
		Global.battle_stage.add_child(projectile)
		projectile.global_position = _muzzle_position
		
		t.tween_property(projectile, "global_position", target_position, projectile_flight_duration)
		var projectile_timer := get_tree().create_timer(projectile_flight_duration)
		projectile_timer.timeout.connect(func():
			projectile.queue_free()
			attack_target.handle_attacked(config, attacker, attack_timestamp, target_position))
		# override for randomness
		target_position = attack_target.get_projectile_point()
		
		if config.inter_projectile_delay > 0:
			await get_tree().create_timer(config.inter_projectile_delay).timeout
	
	return max(recoil_duration, projectile_flight_duration)
