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
