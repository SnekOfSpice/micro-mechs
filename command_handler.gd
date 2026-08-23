extends Node

signal commands_changed()

var command_queue : Array[Command] = []
var undo_queue : Array[Command] = []
var awaiting_execution : bool = false



var world : World


# this local handling is fine for a demo but should be put into global scope for larger projects

func add_command(command : Command) -> void:
	command_queue.append(command)
	
	execute_next_command()



func execute_next_command() -> void:
	commands_changed.emit()
	
	if awaiting_execution or command_queue.is_empty():
		return
		
	awaiting_execution = true
		
	var command : Command = command_queue.front()
	
	await command.execute()
	undo_queue.push_front(command_queue.pop_front())
	awaiting_execution = false
	execute_next_command()

func undo_last_command() -> void:
	if awaiting_execution or undo_queue.is_empty():
		return
	
	awaiting_execution = true
	var command : Command = undo_queue.pop_front()
	
	commands_changed.emit()
	
	await command.undo()
	awaiting_execution = false
	execute_next_command()
