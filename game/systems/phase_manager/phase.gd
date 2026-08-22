## Base class for States managed by [PhaseManager].
extends Node
class_name Phase


@export var state_name : StringName
## if true, will signal the exit when entering.
## so when all clients have enterec the phase,
## the phase manager automatically goes to the next phase
@export var implicit_exit := false
var state_machine : PhaseManager


func _ready() -> void:
	if state_name == "":
		self.state_name = self.name


func enter_state() -> void:
	if implicit_exit:
		PhaseManager.advance_phase()
		return
	#Global.get_local_player().ui.notify("new phase! %s" % self.state_name)


func exit_state() -> void:
	pass
