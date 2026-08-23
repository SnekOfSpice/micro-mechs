extends Node

signal commands_changed()
signal command_executed(command : Command)
signal command_executing(command : Command)

var command_queue : Array[Command] = []
var awaiting_execution : bool = false


func clear():
	command_queue.clear()
	awaiting_execution = false


func add_command(command : Command) -> void:
	command_queue.append(command)
	execute_next_command()


func execute_next_command() -> void:
	commands_changed.emit()
	
	if awaiting_execution or command_queue.is_empty():
		return
		
	awaiting_execution = true
		
	var command : Command = command_queue.pop_front()
	command_executing.emit(command)
	
	@warning_ignore("redundant_await")
	await command.execute()
	await get_tree().create_timer(0.5).timeout
	awaiting_execution = false
	execute_next_command()
	
	command_executed.emit(command)
