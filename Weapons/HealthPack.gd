extends Spatial

onready var resources = $"../../Resources"
onready var switcher = get_parent()
onready var use_audio = $UseAudio

func _physics_process(delta):
	if Input.is_action_just_pressed("fire") and resources.gain_health(50):
		switcher.spend_ammo(1)
		use_audio.play()
