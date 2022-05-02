extends Spatial


func _ready():
	print("Ready")
	# Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$AnimationPlayer.play("spin")
	Input.set_custom_mouse_cursor(
		load("res://assets/icons/crossair_black.png"),
		Input.CURSOR_ARROW, Vector2(16,16)
	)

func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _on_TextureButton_pressed():
	get_tree().change_scene("res://Environment/World.tscn")
