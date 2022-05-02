extends AudioStreamPlayer

export var play_music = true

func _ready():
	if play_music:
		play()

func _on_Music_finished():
	play()
