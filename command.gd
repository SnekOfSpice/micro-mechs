@abstract class_name Command extends Resource

signal command_completed()


enum TargetMode{
	Players
}


@export_placeholder("res://...") var command_name : String
var target_mode := TargetMode.Players
var targets := []


# return boolean to make async calls easier. if you have
# an await in the execute or undo, makes it so other scripts can await the execute call
# use return false for instant execution

@abstract func execute() -> bool
