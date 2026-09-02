extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for button : Button in %TorsoSelector.get_children():
		button.pressed.connect(
			func():
				$Mech.config.torso_id = button.text
				_update_weapons_selection()
		)
	for button : Button in %LegsContainer.get_children():
		button.pressed.connect(
			func():
				$Mech.config.leg_id = button.text
		)
	
	var config := ResourceLoader.load("user://mech_config.tres")
	if config:
		$Mech.config = config
		$Mech.config.changed.connect(_on_config_changed)
	_on_config_changed()
	_update_weapons_selection()

func _on_config_changed():
	await get_tree().process_frame
	var combat_stats : CombatStats = $Mech.initialize_combat_stats()
	
	%MechStatusContainer.display_combat_stats(combat_stats)
	
	%MobilityLabel.text = str("Movement: ", $Mech._leg_config.movement)
	%MobilityLabel.text += str("\nStomp Damage: ", Global.vec2_to_range_string($Mech._leg_config.stomp_damage))


func _update_weapons_selection():
	for child in %WeaponsSelection.get_children():
		child.queue_free()
	
	var weapons := Global.get_weapon_configs()
	
	var weapon_count : int = $Mech.weapon_capacity
	for i in weapon_count:
		#var weapon_selected_here := weapons_selected[i]
		var selections := VBoxContainer.new()
		%WeaponsSelection.add_child(selections)
		for w in weapons:
			var button := Button.new()
			button.text = w
			button.pressed.connect(func():
				$Mech.config.set_weapon(i, button.text)
				)
			selections.add_child(button)
			
			button.mouse_entered.connect(func():
				%AttackInfos.show()
				var config : WeaponConfig = load("res://parts/weapons/configs/%s.tres" % w)
				%AttackInfoDisplay.render(config, AttackInfoDisplay.Perspective.ATTACKER)
				%AttackInfoDisplay2.render(config, AttackInfoDisplay.Perspective.DEFENDER)
				)
			button.mouse_exited.connect(func():
				%AttackInfos.hide())
			


func _on_close_button_pressed() -> void:
	ResourceSaver.save($Mech.config, "user://mech_config.tres")
	get_tree().change_scene_to_file("res://game/main_menu/main_menu.tscn")
