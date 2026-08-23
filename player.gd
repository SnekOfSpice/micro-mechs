class_name Player extends Node2D



func command_spin():
	var c = CommandSpin.new()
	c.targets = [self]
	CommandHandler.add_command(c)
func command_spin_all():
	print("CUT")
	#var c = CommandSpin.new()
	#c.targets = CommandHandler.world.get_players()
	#CommandHandler.add_command(c)
func command_move():
	var c = CommandMove.new()
	c.targets = [self]
	c.target_position = get_global_mouse_position()
	CommandHandler.add_command(c)

func rotate_animation(to:int) -> Tween:
	var tween := create_tween()
	tween.tween_property(self, "rotation_degrees", to, 0.5)
	return tween

func move_animation(target_position : Vector2, duration : float) -> Tween:
	var tween := create_tween()
	tween.tween_property(self, "position", target_position, duration)
	return tween
