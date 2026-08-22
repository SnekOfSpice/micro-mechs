@tool
extends Sprite2D
class_name Torso



@export var weapon_count := 0:
	set(value):
		weapon_count = max(0, value)
		
		if not is_inside_tree():
			return
		
		var pivot_count : int = %WeaponTransforms.get_child_count()
		if pivot_count == weapon_count:
			return
		
		# add additional remotetransforms
		if pivot_count < weapon_count:
			var difference := weapon_count - pivot_count
			for i in difference:
				var remote_transform := RemoteTransform2D.new()
				%WeaponTransforms.add_child(remote_transform)
				remote_transform.owner = get_tree().edited_scene_root
		
		# cull excess remotetransforms
		if pivot_count > weapon_count:
			for i in pivot_count - weapon_count:
				var remote_transform = %WeaponTransforms.get_child(%WeaponTransforms.get_child_count() - 1)
				remote_transform.free()



func hook_up_legs(leg_front : Pivot, leg_back : Pivot):
	%LegTransformFront.remote_path = leg_front.get_path()
	%LegTransformBack.remote_path = leg_back.get_path()
	
	leg_front.in_front = true
	leg_back.in_front = false


func set_weapon(pivot_index : int, weapon : Pivot):
	if pivot_index >= weapon_count:
		push_warning("Tried to add weapon outside of weapon count.")
		return
	
	var remote_transform : RemoteTransform2D = %WeaponTransforms.get_child(pivot_index)
	remote_transform.remote_path = weapon.get_path()
	
	weapon.in_front = pivot_index % 2 == 0


func free_weapon(weapon_index : int):
	var remote_transform : RemoteTransform2D = %WeaponTransforms.get_child(weapon_index)
	if not remote_transform:
		return
	if remote_transform.remote_path.is_empty():
		return
	var weapon := get_node(remote_transform.remote_path)
	if weapon: # can be null if no weapon is set
		weapon.queue_free()


func set_flipped(flipped : bool):
	if flip_h == flipped:
		return
	
	flip_h = flipped
	for t : RemoteTransform2D in %WeaponTransforms.get_children():
		t.position.x = -t.position.x
	
	%LegTransformBack.position.x = -%LegTransformBack.position.x
	%LegTransformFront.position.x = -%LegTransformFront.position.x
	
