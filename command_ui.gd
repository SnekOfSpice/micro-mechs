class_name CommandUI extends CanvasLayer

var player : Player
@onready var command_list: VBoxContainer = %CommandList
@onready var undo_list: VBoxContainer = %UndoList
@onready var undo_button: Button = %UndoButton


signal spin()
signal move()

func _init(p_player : Player) -> void:
	player = p_player
	player = get_parent()
	spin.connect(player.command_spin)
	move.connect(player.command_move)
	%SpinButton.text = "spin %s" % player.name



func on_command_added() -> void:
	for c in command_list.get_children():
		c.free()
	for c in undo_list.get_children():
		c.free()
	
	for c in CommandHandler.command_queue:
		command_list.add_child(create_label(c))
	for c in CommandHandler.undo_queue:
		undo_list.add_child(create_label(c))




func create_label ( command : Command) -> Label:
	var new_label := Label.new()
	new_label.text = command.command_name
	return new_label


func _on_spin_button_pressed() -> void:
	spin.emit()


func _on_control_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			move.emit()



func _on_undo_button_pressed() -> void:
	CommandHandler.undo_last_command()
