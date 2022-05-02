extends Spatial

var cooldown_time = 1.0
var cooldown_timer = 0.0

onready var progress_bar = $Viewport/ProgressBar
onready var progress_label = $Viewport/ProgressLabel

func _ready():
	# If I just set it as a parameter on sprite 3D, it throws errors during runtime.
	$Sprite3D.texture = $Viewport.get_texture()

func _process(delta):
	if cooldown_timer > 0:
		show()
		cooldown_timer -= delta
		cooldown_timer = max(cooldown_timer, 0)
		progress_bar.value = (cooldown_timer / cooldown_time) * 100
		progress_label.text = str(stepify(cooldown_timer,0.1))
	else:
		hide()


func activate_cooldown(cooldown_length):
	$ReloadStartAudio.play()
	cooldown_time = cooldown_length
	cooldown_timer = cooldown_length
