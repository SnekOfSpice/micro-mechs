extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	StockMarketManager.add_time()

	for stock in StockMarketManager.Stock.size():
		printt(stock, StockMarketManager.get_price_multiplier(stock))


func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://game/main_menu/main_menu.tscn")
