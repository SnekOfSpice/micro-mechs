extends Node


enum Stock{
	GUNS,
	TORSOS
}

const STOCK_SEED_PATH := "user://stock_seeds.json"
var STOCK_SEED_PASS : PackedByteArray = "435555372".sha256_buffer()

var seeds : Dictionary[Stock, int] = {}
var elapsed_time : float = 0.0

var amplifier_noise_by_stock : Dictionary [Stock, FastNoiseLite] = {}
var base_noise_by_stock : Dictionary [Stock, FastNoiseLite] = {}

func _ready() -> void:
	# fetch from file if exists
	var loaded_data : Dictionary = FileLoader.get_encrypted(STOCK_SEED_PATH, STOCK_SEED_PASS)
	for key in loaded_data.keys():
		seeds[int(key) as Stock] = loaded_data.get(key)
	
	for stock in Stock.size():
		if not stock in seeds:
			seeds[stock] = randi()
	save_stocks()
	
	for stock : Stock in seeds.keys():
		var base_noise := FastNoiseLite.new()
		base_noise.seed = seeds.get(stock)
		base_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
		base_noise_by_stock[stock] = base_noise
		
		var amplifier_noise := FastNoiseLite.new()
		amplifier_noise.seed = seeds.get(stock)
		amplifier_noise.noise_type = FastNoiseLite.TYPE_CELLULAR
		amplifier_noise_by_stock[stock] = amplifier_noise
	
func save_stocks():
	FileLoader.save_encrypted(STOCK_SEED_PATH, STOCK_SEED_PASS, seeds)


func add_time():
	var amount := time_since_last_add
	elapsed_time += amount
	time_since_last_add = 0


var time_since_last_add := 0.0

func _process(delta: float) -> void:
	time_since_last_add += delta

func get_price_multiplier(stock : Stock) -> float:
	var base : float = base_noise_by_stock.get(stock).get_noise_1d(elapsed_time)
	var amplifier : float = amplifier_noise_by_stock.get(stock).get_noise_1d(elapsed_time)
	
	base += 1.0
	amplifier += 1.0
	
	base *= 0.5
	amplifier *= 0.5
	
	return base * amplifier
