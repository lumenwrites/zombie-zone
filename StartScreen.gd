extends CanvasLayer

onready var score = $CenterContainer/VBoxContainer/CenterContainer/HBoxContainer/Score

func _ready():
	score.text = str(Save.save_data["high_score"])
