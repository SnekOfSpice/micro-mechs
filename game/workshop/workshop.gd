extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for button : Button in %TorsoSelector.get_children():
		button.pressed.connect(
			func():
				$Mech.config.torso_id = button.text
		)
	for button : Button in %LegsContainer.get_children():
		button.pressed.connect(
			func():
				$Mech.config.leg_id = button.text
		)
	
	var config := ResourceLoader.load("user://mech_config.tres")
	if config:
		$Mech.config = config


func _on_close_button_pressed() -> void:
	ResourceSaver.save($Mech.config, "user://mech_config.tres")
	get_tree().change_scene_to_file("res://game/main_menu/main_menu.tscn")
