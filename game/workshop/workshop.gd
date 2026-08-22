extends Control


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
	%CombatStatsLabel.text = "health : %s" % combat_stats.health_max


func _update_weapons_selection():
	for child in %WeaponsSelection.get_children():
		child.queue_free()
	
	var weapons := ["cannon_1", "cannon_2", "cannon_3"]
	var weapons_selected : PackedStringArray = $Mech.config.weapon_list
	
	var weapon_count : int = $Mech.weapon_capacity
	for i in weapon_count:
		#var weapon_selected_here := weapons_selected[i]
		var selections := VBoxContainer.new()
		%WeaponsSelection.add_child(selections)
		for w in weapons:
			var button := Button.new()
			button.text = w
			button.pressed.connect(func():
				printt(i, button.text)
				$Mech.config.set_weapon(i, button.text)
				)
			selections.add_child(button)


func _on_close_button_pressed() -> void:
	ResourceSaver.save($Mech.config, "user://mech_config.tres")
	get_tree().change_scene_to_file("res://game/main_menu/main_menu.tscn")
