extends Node2D
class_name World

const PLAYER = preload("res://player.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	CommandHandler.world = self
