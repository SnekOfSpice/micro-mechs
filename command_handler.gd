extends Node

signal commands_changed()
signal command_executed(command : Command)

var command_queue : Array[Command] = []
var awaiting_execution : bool = false


func add_command(command : Command) -> void:
	command_queue.append(command)
	execute_next_command()


func execute_next_command() -> void:
	commands_changed.emit()
	
	if awaiting_execution or command_queue.is_empty():
		return
		
	awaiting_execution = true
		
	var command : Command = command_queue.pop_front()
	await get_tree().create_timer(0.5).timeout
	
	@warning_ignore("redundant_await")
	await command.execute()
	awaiting_execution = false
	execute_next_command()
	
	command_executed.emit(command)
