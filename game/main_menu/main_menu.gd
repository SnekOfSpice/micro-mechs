extends Control



func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_battle_button_pressed() -> void:
	get_tree().change_scene_to_file("res://world/battle/battle_stage.tscn")


func _on_workshop_button_pressed() -> void:
	get_tree().change_scene_to_file("res://game/workshop/workshop.tscn")


func _on_stock_market_button_pressed() -> void:
	get_tree().change_scene_to_file("res://stock_market/stock_market.tscn")
