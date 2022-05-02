extends Node


const SAVE_GAME = "user://zombie-zone-savegame.json"
var save_data = {
	"high_score": 0
}

func _ready():
	load_data()

func save_data():
	var file = File.new()
	file.open(SAVE_GAME, File.WRITE)
	file.store_line(to_json(save_data))
	file.close()

func load_data():
	var file = File.new()
	
	if not file.file_exists(SAVE_GAME):
		save_data = {"high_score": 0}
		save_data()

	file.open(SAVE_GAME, File.READ)
	var content = file.get_as_text()
	var data = parse_json(content)
	save_data = data
	file.close()
	
	print("Load data ", save_data)
	return data


