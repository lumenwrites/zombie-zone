extends Spatial

# https://www.youtube.com/watch?v=rCLFMd8WN8M

export (Color) var color = Color("#3ba523")
export var height = 30

onready var viewport = $Viewport
onready var progress_bar = $Viewport/ProgressBar

func _ready():
	var new_style = StyleBoxFlat.new()
	new_style.set_bg_color(color)
	progress_bar.set('custom_styles/fg', new_style)
	
	progress_bar.rect_size.y = height
	viewport.size.y = height

	update_progressbar(100, 100)
	# If I just set it as a parameter on sprite 3D, it throws errors during runtime.
	$Sprite3D.texture = $Viewport.get_texture()


func update_progressbar(current_value, max_value):
	progress_bar.value = current_value * 100/max_value
	if current_value < max_value and current_value > 0:
		$Sprite3D.show()
	else:
		$Sprite3D.hide()
